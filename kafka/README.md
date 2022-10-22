# kafka

    w celu przetestowania tworzenia topicow / pisania i czytania z kafki uruchmoić aplikację z elementu kafka-tester.yaml i użyć poniższe wewnatrz poda kafka-tester

	#lista topicow

        /usr/bin/kafka-topics --zookeeper zookeeper:2181 --list
 	
 	#dodawanie topica
        /usr/bin/kafka-topics --zookeeper zookeeper:2181 --topic test1 --create --partitions 1 --replication-factor 1

 	#producer
        /usr/bin/kafka-console-producer --broker-list kafka-headless:9092 --topic test1

 	#consumer
        /usr/bin/kafka-console-consumer --bootstrap-server kafka:9092 --topic test1 --from-beginning
