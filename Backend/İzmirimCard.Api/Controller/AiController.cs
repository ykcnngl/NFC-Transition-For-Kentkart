using Microsoft.AspNetCore.Mvc;
using System.Text;
using System.Text.Json;

namespace IzmirimCard.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AiController : ControllerBase
    {
        private readonly string _geminiApiKey = "API_KEY"; 
        
        private readonly string _googleMapsApiKey = "API_KEY"; 

        [HttpPost("chat")]
        public async Task<IActionResult> AskAssistant([FromBody] ChatRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Message))
                return BadRequest(new { message = "Soru boş olamaz." });

            try
            {
                // =========================================================================
                // ADIM 1: NLU - KULLANICI CÜMLESİNİ JSON'A ÇEVİR
                // =========================================================================
                string sampleJson = "{ \"kalkis\": \"Konak\", \"varis\": \"Urla\", \"saat\": \"13:00\" }";
                
                string extractPrompt = @"Sen bir veri analiz botusun. Kullanıcının cümlesinden 'Kalkış' ve 'Varış' ilçelerini/yerlerini bul. 
Eğer cümlede sadece iki yer ismi varsa (Örn: 'Urla Konak 13.00'), ilkini Kalkış, ikincisini Varış kabul et.
SADECE geçerli bir JSON dön. Markdown KULLANMA.

Kullanıcı Cümlesi: " + request.Message + @"
Örnek Çıktı Formatı: " + sampleJson;

                Console.WriteLine("--- ADIM 1: GEMINI'DEN JSON İSTENİYOR ---");
                string extractedJson = await CallGeminiApiAsync(extractPrompt, 0.1);
                extractedJson = extractedJson.Replace("```json", "").Replace("```", "").Trim();
                Console.WriteLine("GELEN JSON: " + extractedJson);

                RouteExtractModel? routeData;
                try 
                {
                    routeData = JsonSerializer.Deserialize<RouteExtractModel>(extractedJson, new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                } 
                catch (Exception ex)
                {
                    Console.WriteLine("HATA: JSON Parse edilemedi! Sebebi: " + ex.Message);
                    return await DuzGeminiCevabiVer(request.Message);
                }

                if (routeData == null || string.IsNullOrWhiteSpace(routeData.Kalkis) || string.IsNullOrWhiteSpace(routeData.Varis))
                {
                     Console.WriteLine("HATA: Kalkış veya Varış noktası bulunamadı. B Planına Geçiliyor.");
                     return await DuzGeminiCevabiVer(request.Message);
                }

                // =========================================================================
                // ADIM 2: RETRIEVAL - GOOGLE MAPS API'DEN CANLI VERİ ÇEK
                // =========================================================================
                string origin = Uri.EscapeDataString(routeData.Kalkis + " İzmir");
                string destination = Uri.EscapeDataString(routeData.Varis + " İzmir");
                
                string mapsUrl = $"https://maps.googleapis.com/maps/api/directions/json?origin={origin}&destination={destination}&mode=transit&language=tr&key={_googleMapsApiKey}";

                Console.WriteLine($"--- ADIM 2: GOOGLE MAPS'E İSTEK ATILIYOR ---");
                Console.WriteLine($"URL: {mapsUrl}");

                using var httpClient = new HttpClient();
                var mapsResponse = await httpClient.GetAsync(mapsUrl);
                string mapsJsonData = await mapsResponse.Content.ReadAsStringAsync();

            
                if (!mapsJsonData.Contains("\"status\" : \"OK\""))
                {
                     Console.WriteLine("HATA: Google Maps'ten OK durumu dönmedi!");
                     Console.WriteLine("GOOGLE CEVABI: " + mapsJsonData.Substring(0, Math.Min(200, mapsJsonData.Length)));
                }
                else
                {
                     Console.WriteLine("BAŞARILI: Google Maps'ten rota verisi alındı.");
                }

                // =========================================================================
                // ADIM 3: AUGMENTED GENERATION - CANLI VERİYİ GEMINI'A GÖM
                // =========================================================================
                Console.WriteLine("--- ADIM 3: RAG (GOOGLE VERİSİ GEMINI'A VERİLİYOR) ---");
                
                string finalSystemPrompt = @"Sen İzmir Büyükşehir Belediyesi'nin resmi asistanı Efe'sin.
GÖREVİN: Sana aşağıda verilen 'CANLI GOOGLE HARİTALAR ROTA VERİSİ'ni (JSON) kullanarak kullanıcıya EN KISA rotayı anlatmaktır.

CANLI GOOGLE HARİTALAR ROTA VERİSİ:
" + mapsJsonData + @"

KESİN KURALLAR:
1. YALNIZCA sana yukarıda verdiğim JSON verisi içindeki 'transit_details' (line, short_name, vs.) bilgilerini kullan.
2. ESHOT, İZBAN veya Metro numaralarını/isimlerini kesinlikle JSON'dan al, YALAN/UYDURMA NUMARA YAZMA.
3. Kısa ve adım adım cevap ver. 
4. 'Merhaba ben Efe' deme, direkt 'Şu rotayı izleyebilirsiniz:' diye başla.
5. Eğer JSON içinde toplu taşıma verisi bulamazsan, 'Şu an bu rota için doğrudan toplu taşıma seferi bulamadım.' de.";

                string finalResponse = await CallGeminiApiAsync(finalSystemPrompt, 0.1); 

                return Ok(new { success = true, reply = finalResponse });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"\n[AI RAG SİSTEM HATASI] {ex.Message}\n");
                return await DuzGeminiCevabiVer(request.Message);
            }
        }

        // -------------------------------------------------------------------------
        // YARDIMCI METOTLAR
        // -------------------------------------------------------------------------

        private async Task<IActionResult> DuzGeminiCevabiVer(string userMessage)
        {
            string fallbackPrompt = @"Sen İzmir Büyükşehir Belediyesi'nin resmi asistanı Efe'sin.
Amacın kullanıcılara A noktasından B noktasına gitmek için yönlendirme yapmaktır.
KURALLAR:
1. ASLA destan yazma. Laf kalabalığı yapma. 
2. 'Vapur yoktur' gibi seçenekleri açıklama. 
3. Asla uydurma ESHOT hat numaraları üretme. Emin değilsen 'Duraklardaki bilgilendirmeleri veya uygulamayı kontrol edin' de.
4. 'Merhaba ben Efe' deme, direkt konuya gir.";

            string fullPrompt = fallbackPrompt + "\n\nKullanıcı Sorusu: " + userMessage;
            string reply = await CallGeminiApiAsync(fullPrompt, 0.1);
            
            return Ok(new { success = true, reply = reply });
        }

        private async Task<string> CallGeminiApiAsync(string prompt, double temperature)
        {
            string apiUrl = $"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key={_geminiApiKey}";

            var requestBody = new
            {
                contents = new[] { new { parts = new[] { new { text = prompt } } } },
                generationConfig = new
                {
                    temperature = 0.1,
                    topK = 40,
                    topP = 0.95,
                    maxOutputTokens = 1000
                }
            };

            using var httpClient = new HttpClient();
            var content = new StringContent(JsonSerializer.Serialize(requestBody), Encoding.UTF8, "application/json");

            var response = await httpClient.PostAsync(apiUrl, content);
            var responseData = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                using var doc = JsonDocument.Parse(responseData);
                return doc.RootElement
                    .GetProperty("candidates")[0]
                    .GetProperty("content")
                    .GetProperty("parts")[0]
                    .GetProperty("text")
                    .GetString() ?? "Cevap üretilemedi.";
            }
            else
            {
                throw new Exception($"Gemini API Hatası: {responseData}");
            }
        }
    }

    public class RouteExtractModel
    {
        public string Kalkis { get; set; } = string.Empty;
        public string Varis { get; set; } = string.Empty;
        public string Saat { get; set; } = string.Empty;
    }

    public class ChatRequest
    {
        public string Message { get; set; } = string.Empty;
    }
}