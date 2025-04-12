# Server-Monitoring-System

Hello! This is my Server Monitoring System -> the script that collects and analyzes data on the use of system resources (CPU, memory, disk) and sends notifications when the indicators exceed the established thresholds.

If you wanna test this program, I hope you want) You need to do next things:
1) You need to find '@BotFather' in telegram 
2) Send him a command '/newbot'
3) Input some name for your bot
4) Input a unique user name for bot(must end with 'bot')

After you did it, bot will send you a massage with link for chating with your bot and a TOKEN.
Start the dialogue with Bot by clicking on the link and write something like 'hello'. 
Your next step is that you openning the browser and go to this link https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates

Change <YOUR_BOT_TOKEN> with your token

You must see some info like "chat":{"id":123456789} and the numer in this field it is your ID

If you do not see any info about ID, clear a chat history with your bot, start chat again and restart a page in browser.

Last thing use this token and ID in server_monitor.sh file, you will see my comments where you need to change it and that's all!

I Hope you will like it)


Oleksandr Ovdiienko :)
