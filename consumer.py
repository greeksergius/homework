credentials = pika.PlainCredentials('admin', 'password')
parameters = pika.ConnectionParameters('192.168.0.10',
                                   5672,
                                   '/',
                                   credentials)

#connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
#channel = connection.channel()
#connection = pika.BlockingConnection(parameters)
#channel.queue_declare(queue='hellokey')

connection = pika.BlockingConnection(parameters)
channel = connection.channel()

channel.queue_declare(queue='hellokey')

def callback(ch, method, properties, body):
    print(" [x] Received %r" % body)

#channel.basic_consume(callback, queue='hello', no_ack=True)
channel.basic_consume(queue='hellokey', on_message_callback=callback, auto_ack=True)
channel.start_consuming()
