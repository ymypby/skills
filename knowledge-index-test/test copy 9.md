## 版本说明


| 发布日期       | 修改人 | 版本号     | 修改内容             |
| ---------- | --- | ------- | ---------------- |
| 2024-04-01 | 付鹏远 | 1.2.4   | 删减不必要日志。         |
| 2023-02-01 | 付鹏远 | 1.2.2   | 性能优化，规范jar包引入版本  |
| 2023-12-29 | 付鹏远 | 1.2.0   | 规范依赖版本。          |
| 2023-08-29 | 付鹏远 | 1.1.4.1 | 基础功能提交仓库，原始功能开发。 |


## 功能简述

框架对异步任务进行统筹管理，实现了资源统一分配、异常统一处理、监控统一实施的三统一，且对任务按需进行分类  
并为他们分配独立的线程池和任务队列。调用方只需关心具体业务的实现并在需要时登记异步任务，登记的异步任务会被框架自动消费掉 ，调用方不需要关心被消费的过程 

## 依赖说明


| 模块                          | 版本号           | 作用             |
| --------------------------- | ------------- | -------------- |
| autm-asyntask-kafka         | 1.0.0.RELEASE | autm核心包        |
| autm-asyntask-api           | 1.0.0.RELEASE | autm核心包        |
| autm-asyntask-autoconfig    | 1.0.0.RELEASE | autm核心包        |
| autm-asyntask-commons       | 1.0.0.RELEASE | autm核心包        |
| mybatis-spring-boot-starter | 2.1.2         | mybatis        |
| sirius-amc                  | 1.0.41        | amc            |
| autm-spring-utils           | 0.0.3.RELEASE | autm封装的spring包 |
| autm-commons-utils          | 0.1.7.RELEASE | autm基础工具包      |
| slf4j-api                   | 1.7.26        | 日志             |
| spring-kafka                | 2.2.8.RELEASE | spring的kafka组件 |
| kafka_2.12                  | 1.1.1         | kafka客户端       |
| zookeeper                   | 3.4.9         | zookeeper      |
| jopt-simple                 | 5.0.2         | java命令行解析包     |
| zkClient                    | 0.2           | zkClient工具     |


## 使用说明

## 一：引入依赖

```xml
 
<dependency> 
    <groupId>com.icbc.panda</groupId> 
    <artifactId>panda-asyntask-core</artifactId> 
    <version>1.2.8</version> 
</dependency> 
```

## 二：在数据库中建表

在使用异步任务之前，需建  

1、异步任务定义表  

2、异步子任务定义表  

3、异步任务明细表  

4、异步任务历史明细表。  

具体表结构如下：  

```
1、	表英文名	表中文名							 
	panda_asyn_task_def	异步任务定义表							 
序号	字段	字段类型	说明	主键	非空	唯一	约束	外键	默认值 
1	TASK_TYPE	varchar(20)	任务类型，主键-按此区分线程池	1	Y	Y			 
2	TASK_NAME	varchar(100)	任务名称		Y				 
3	TASK_IMPL	varchar(200)	"任务实现类，IAsynTask的实现类，即制定此类型的任务具体作业内容执行该实现类。 
注：当没有子任务类型时使用此类，否则留空"		Y				 
4	FETCH_TASK_INTERVAL	int(10)	取待处理任务时间间隔（毫秒），即AsynTaskGetTaskThread休眠时间		Y				 
5	FETCH_TASK_COUNT	int(10)	单次取待处理任务的记录数，即AsynTaskGetTaskThread任务抢占记录数		Y				 
6	EXECUTE_TASK_DELAY	int(10)	将待处理任务放入消息队列延迟（毫秒），即AsynTaskGetTaskThread塞入线程池延时时间						 
7	MIN_POOL_SIZE	int(10)	线程池初始值		Y				 
8	MAX_POOL_SIZE	int(10)	线程池最大线程数		Y				99 
9	QUEUE_LIMIT	int(10)	队列最大深度，超过该值将调用AsynTaskMonitor接口		Y				 
10	REDO_COUNT	int(10)	最大重试次数（默认值）						 
11	REDO_INTERVAL	int(10)	重做时间间隔（秒）						 
12	TIMEOUT_LIMIT	int(10)	任务超时时间（秒）						 
13	TIMEOUT_CHECK_INTERVAL	int(10)	超时检查时间间隔（毫秒）						 
14	RESEND_MAX_COUNT	int(10)	消息推送最大重发次数						 
15	RESEND_INTERVAL	int(10)	消息推送重发间隔（秒）						 
16	RESEND_SLEEP_INTERVAL	int(10)	消息推送线程休息时间（毫秒）						 
17	LAST_DATE	datetime	最后修改时间						 
	索引名	字段名	创建人	更新人					 
	PK_panda_asyn_task_def	TASK_TYPE			主键				 
 
2、	panda_asyn_sub_task_def	异步子任务定义表				 
序号	字段	字段类型	说明	主键	非空	唯一 
1	TASK_TYPE	varchar(20)	任务类型	1	Y	Y 
2	SUB_TASK_TYPE	varchar(20)	子任务类型		Y	 
2	SUB / 6: 
_TASK_NAME	varchar(100)	子任务名称			 
3	SUB_TASK_IMPL	varchar(200)	子任务实现类			 
4	PRIORITY	TINYINT	优先级			 
	PK_panda_asyn_sub_task_def	TASK_TYPE,SUB_TASK_TYPE			主键	 
 
3、	panda_asyn_task_dtl	异步任务明细表			 
序号	字段	字段类型	说明	主键	非空 
1	TASK_ID	int(11)	主键，任务序号	1	Y 
2	KEYWORDS	varchar(100)	任务关键字（关联业务表主键）		 
3	TASK_TYPE	varchar(20)	任务类型		 
4	SUB_TASK_TYPE	varchar(20)	子任务类型		 
5	STATE 	varchar(6)	任务状态(0待处理 1进入队列 2开始工作 3任务成功 4任务失败 5超时被杀 6超时被抢 7任务撤销 8)		Y 
6	PRIORITY	TINYINT	优先级		 
7	APPLY_TIME	datetime	提交时间		 
8	IN_QUEUE_TIME	datetime	进入队列时间		 
9	IP	varchar(64) 	抢占ip		Y 
10	THREAD_ID	varchar(40)	工作线程号		 
11	START_WORK_TIME	datetime	开始工作时间		 
12	END_WORK_TIME	datetime	结束工作时间		 
13	ERR_CODE	varchar(20)	错误代码		 
14	ERR_MSG	varchar(1000)	错误信息		 
15	REDO_COUNT	int(10)	最大重试次数（默认值）		 
16	DEAL_NUM	TINYINT	当前处理次数		 
17	PLAN_TIME	datetime	计划执行时间(如果实时就为空)		 
18	END_TIME	datetime	截止时间 到达截止时间如果短信没有发送则不再发送短信		 
19	REQUEST	text	外部服务请求短信服务报文		 
20	SMS_REQUEST	text	工作线程业务关联字段-调用接口请求报文		 
21	SMS_RESPONSE	text	工作线程业务关联字段-调用接口响应报文		 
22	TIMEOUT_LIMIT	int(11)	超时时间限制		 
23	INFO1 	text	备注1、会被kafka占用		 
24	INFO2	text	备注2、会被kafka占用		 
25	INFO3	text	备注2、会被kafka占用		 
26	CREATE_TIME	datetime	创建时间		 
27	UPDATE_TIME	datetime	更新时间		 
	panda_asyn_task_dtl_IDX1	TASK_TYPE，STATE，IP			 
	PK_panda_asyn_task_dtl	TASK_ID			 
 
4、	panda_asyn_task_dtl_his	异步任务历史明细表				 
序号	字段	字段类型	说明	主键	非空	唯一 
1	TASK_ID	int(11)	主键，任务序号	1	Y	 
2	PART_ID	varchar(2)	分区号			 
3	KEYWORDS	varchar(100)	任务关键字（关联业务表主键）			 
4	TASK_TYPE	varchar(20)	任务类型			 
5	SUB_TASK_TYPE	varchar(20)	子任务类型			 
6	STATE 	varcha / 6: 
r(6)	任务状态(0待处理 1进入队列 2开始工作 3任务成功 4任务失败 5超时被杀 6超时被抢 7任务撤销 8)			 
7	PRIORITY	TINYINT	优先级			 
8	APPLY_TIME	datetime	提交时间			 
9	IN_QUEUE_TIME	datetime	进入队列时间			 
10	IP	varchar(64) 	抢占ip			 
11	THREAD_ID	varchar(40)	工作线程号			 
12	START_WORK_TIME	datetime	开始工作时间			 
13	END_WORK_TIME	datetime	结束工作时间			 
14	ERR_CODE	varchar(20)	错误代码			 
15	ERR_MSG	varchar(1000)	错误信息			 
16	REDO_COUNT	int(10)	最大重试次数（默认值）			 
17	DEAL_NUM	TINYINT	当前处理次数			 
18	PLAN_TIME	datetime	计划执行时间(如果实时就为空)			 
19	END_TIME	datetime	到达截止延时时间如果短信没有发送则不再发送短信			 
20	REQUEST	text	外部服务请求短信服务报文			 
21	SMS_REQUEST	text	工作线程业务关联字段-调用接口请求报文			 
22	TIMEOUT_LIMIT	int(11)	超时时间秒			 
23	INFO1 	text	备注1、会被kafka占用			 
24	INFO2	text	备注2、会被kafka占用			 
25	INFO3	text	备注2、会被kafka占用			 
26	SMS_RESPONSE	text	工作线程业务关联字段-调用接口响应报文			 
27	CREATE_TIME	datetime	创建时间			 
28	UPDATE_TIME	datetime	更新时间			 
						 
	索引名	字段名	创建人	更新人		 
	PK_asyn_task_dtl_his	TASK_ID			主键,自增长	 
```

## 三：配置application.properties

```
Mybatis配置： 
mybatis.mapper-locations=classpath*:mapper/*.xml,classpath*:/mapper/panda/asyntask/gauss/*.xml 
 
kafka配置（注意值的替换）： 
autm.asyntask.kafka.topic=AUTM_KAFKA_ASYN_TASK_TEST,AUTM_KAFKA_ASYN_TASK_FULLCLASS_TEST,testKafkaNoRelation 
spring.kafka.properties.authenticate.enable=true 
spring.kafka.properties.app.id=F-DMQS 
spring.kafka.properties.password=EFE9A92951F0FB03 
key.deserializer=org.apache.kafka.common.serialization.StringDeserializer 
value.deserializer=org.apache.kafka.common.serialization.StringDeserializer 
producer.key.serializer=org.apache.kafka.common.serial / 6: 
ization.StringSerializer 
producer.value.serializer=org.apache.kafka.common.serialization.StringSerializer 
panda.asyntask.kafka.security.protocol=SASL_PLAINTEXT 
panda.asyntask.kafka.sasl.mechanism=SCRAM-SHA-512 
panda.asyntask.kafka.sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="F-BAM-APDUB" password="0D62EBDB4B9178CD44864D297E649188FB7068CE59057BC1F563D353F94C58F0"; 
//多ip使用，隔开 
spring.kafka.bootstrap-servers=127.0.0.1:9092 
spring.kafka.producer.properties.max.block.ms=10000 
spring.kafka.producer.batch-size=16384 
spring.kafka.producer.buffer-memory=33554432 
spring.kafka.producer.acks=1 
spring.kafka.producer.retries=1 
spring.kafka.consumer.bootstrap-servers=127.0.0.1:9092 
spring.kafka.consumer.enable-auto-commit=false 
spring.kafka.consumer.group-id=0 
spring.kafka.listener.poll-timeout=5000ms 
spring.kafka.consumer.max-poll-records=50 
spring.kafka.consumer.properties.partition.assignment.strategy=org.apache.kafka.clients.consumer.RangeAssignor 
//用于任务类型和topic的转换 
autm.asyntask.kafka.topic.suffix=SMS_EINFOMSG:BAM_PANDASMS_GN_INFO,SMS_HW:BAM_PANDASMS_JW_INFO,SMS_RZ:BAM_PANDASMS_GN_VERIFY,SMS_IT:BAM_PANDASMS_GN_IT 
autm.asyntask.kafka.queue-monitor=false 
//amc配置： 
amc.usability.server.ip=122.18.109.93 
amc.usability.server.port=4711 
amc.event.server.ip=122.18.109.93 
amc.event.server.port=2328 
amc.enable.flag=false 
amc.app.name=F-BAM 
amc.image.module=BAM_ISAS 
```

## 四：代码用例

```java
 
@configuration 
@EnableAutmAsynTas(mode = 2) 
public class PandaAsynTaskDemoConfig { 
 
} 
```

## 五：登记异步任务接口调用

#### 5.1 任务插入接口

```java
public class Test { 
    @Autowired 
    DBTaskServiceFactory dbTaskServiceFactory; 
    @Autowired 
    KafkaAsynTaskServiceFactory kafkaAsynTaskServiceFactory; 
 
    public void test() { 
        PandaAsynTaskBean taskBean = new PandaAsynTaskBean(); 
        taskBean.setKeywords("smsService任务"); 
        taskBean.setSubTaskType("");// 赋值空 
        taskBean.setTaskType(request.getRequestType()); 
        taskBean.setRequest(JSON.toJSONString(request)); 
        taskBean.setSmsRequest(""); 
        //根据业务需求set字段值 
        //然后调用接口插入异步任务： 
        KafkaAsynTaskService asynTaskDtlService = 
                (KafkaAsynTaskService) kafkaAsynTaskServiceFactory.getAsynTaskDtlService(taskBean); 
        resultBean = asynTaskDtlService.reg2DbAndKafkaBroker(taskBean); 
    } 
} 
```

#### 5.2 任务实现接口

```java
public class Doservice implements IAsynTask { 
    //一个小小的测试 
    @Override 
    public AsynTaskErrInfo executeTask(AsynTaskBean task) { 
        AsynTaskErrInfo errInfo = new AsynTaskErrInfo(); 
        //业务实现 
        errInfo.setErrMsg("测试一下"); 
        return errInfo; 
    } 
} 
```

#### 5.3 注意事项

组件内部涉及线程定时扫描表,在任务执行时也涉及将任务从明细表移动至历史表。涉及delete和insert操作,当运行一段时间后,如未进行元祖数据的清理,需要手动进行元祖数据的清理，避免数据库的CPU的冲高。