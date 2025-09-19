# aiagentchatbot

This is the project for the interface that interacts with CAIS agents.

## CORE FUNCTIONALITIES

 - CHAT
 - Live audio transcription
 
## chatpage.dart (LANDING PAGE)

    -  _sendMessage() handles the following
        - Read/Write to supabase
            - using Supabasefunctions().sendmessage() || lib/BackendFiles/supabasefunctions.dart
        - Send Payload to Webhook
            - WebhookFunctions().sendPostRequests()  || lib/BackendFiles/webhookfunctions.dart
    - Stream Messages from Database
        - chatblock.dart contains the Textbuble layout
    - AudiotogglePill() to trigger STT
    - _showUserInfoDialog() to add Company Data To payload

## audiotogglepill.dart 
    - Streams Audio from the user, feeds it to Deepgram and assigns the text data from deepgram to the form in the chatpage. 

## supabasefunctions.dart
    - Contains methods that accepts messages from chatpage, and writes it on the DB

## webhookfunctions.dart
    -Contains methods that send payloads to the webhooks, accept payload, and webhook link. 


