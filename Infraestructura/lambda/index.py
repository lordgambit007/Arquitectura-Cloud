import json

def handler(event, context):
    for record in event['Records']:
        # SQS entrega el cuerpo del mensaje en 'body'
        body = json.loads(record['body'])
        
        # SNS guarda el mensaje real dentro del campo "Message"
        message_str = body.get('Message', '{}')
        message = json.loads(message_str)

        print(f"📧 Enviando correo a: {message.get('to')}")
        print(f"📰 Asunto: {message.get('subject')}")
        print(f"💬 Mensaje: {message.get('body')}")
        print("✅ Correo enviado correctamente")

    return {"statusCode": 200}
