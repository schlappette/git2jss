pkill -f bomgar

launchctl unload /Library/LaunchAgents/com.bomgar.bomgar-scc*
rm -rf /Users/Shared/bomgar-scc*
rm -rf /Library/LaunchAgents/com.bomgar.bomgar-scc*
rm -rf /Library/LaunchDaemons/com.bomgar.bomgar-ps*
