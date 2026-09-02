using Microsoft.AspNetCore.SignalR;

namespace IzmirimCard.Api.Hubs
{
    public class IzmirimHub : Hub
    {
        public override async Task OnConnectedAsync()
        {
            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            await base.OnDisconnectedAsync(exception);
        }
    }
}