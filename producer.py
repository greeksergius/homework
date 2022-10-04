import pika
#connection = pika.BlockingConnection(pika.ConnectionParameters('admin', 'password','192.168.56.108'))
credentials = pika.PlainCredentials('admin', 'password')
parameters = pika.ConnectionParameters('192.168.0.6',
                                   5672,
                                   '/',
                                   credentials)
connection = pika.BlockingConnection(parameters)

#connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
#channel = connection.channel()
#connection = pika.BlockingConnection(parameters)
#channel.queue_declare(queue='hellokey')

channel = connection.channel()
channel.queue_declare(queue='hellokey')

count = 0

while True:
    count +=1
    channel.basic_publish(exchange='', routing_key='hellokey', body='Hello Greeka!' + str (count))
connection.close()
