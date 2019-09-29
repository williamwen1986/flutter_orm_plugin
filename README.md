# 移动端orm框架性能测评

[flutter\_orm\_plugin](https://pub.dartlang.org/packages/flutter_orm_plugin) 发布以来，不少团队试用了，我发现大家对这类数据库相关的库，第一反应就是性能如何，之前确实没做太多行业对比，最近觉得还是有必要做一下性能测试，给大家一个交代的。

在ios端，业界比较常用的orm框架应该是苹果官方推出的coredata，还有就是realm了。在android端orm框架我挑了三个比较常用的，greendao，realm和activeandroid。我会用flutter\_orm\_plugin跟上面提到的ios和android端orm框架做对比。 下面我会分别给出测试用例，测试代码，还有最终数据比较的结果。

## 测试用例

测试用例我列了以下这些

* 10000次插入数据
* 使用批量接口10000次插入数据
* 10000次读取数据
* 10000次修改数据
* 使用批量接口10000次修改数据
* 10000次删除数据
* 使用批量接口10000次删除数据

为什么会有普通插入数据和使用批量接口插入数据的区别，大部分orm框架都会对批量操作有一定的优化，所以需要对批量操作进行测试，但是在平时使用，不一定都能用上批量接口（例如多次数据操作不在同一代码块，或者在不同的模块中都要操作数据），所以我们会分别对普通操作和批量操作进行测试。


## android 测试代码

首先我们给出[flutter\_orm\_plugin](https://pub.dartlang.org/packages/flutter_orm_plugin) 的测试代码，由于不想因为flutter和原生channel通讯产生误差，我们直接用[Luakit](https://github.com/williamwen1986/Luakit)来写lua代码做测试（greendao、realm、activeandroid、coredata都不涉及flutter和原生channel通讯），flutter\_orm\_plugin其实底层就是luakit的orm框架，这个不影响测试准确性。

### 循环插入

Luakit定义orm模型结构并做10000次插入，下面的代码是ios和android通用的。

```
	local Student = {
        __dbname__ = "test.db",
        __tablename__ = "Student",
        studentId = {"TextField",{primary_key = true}},
        name = {"TextField",{}},
        claName = {"TextField",{}},
        teacherName = {"TextField",{}},
        score = {"RealField",{}},
    }
     
    local params = {
        name = "Student",
        args = Student,
    }
    
    Table.addTableInfo(params,function ()
    	local studentTable = Table("Student”)
	    for i=1,10000 do
	           local s = {
	               studentId = "studentId"..i,
	               name = "name"..i,
	               claName = "claName"..i,
	               teacherName = "teacherName"..i,
	               score = 90,
	           }
	           studentTable(s):save()
	    end
 	end)

```
activeandroid定义orm模型结构并做10000次插入

```java

@Table(name = "Students")
public class Student extends Base {
    @Column(name = "studentId")
    public String studentId;
    @Column(name = "name")
    public String name;
    @Column(name = "claName")
    public String claName;
    @Column(name = "teacherName")
    public String teacherName;
    @Column(name = "score")
    public float score;
    public Student() {
        super();
    }
    @Override
    public String toString() {
        return this.studentId;
    }
}

for (int i=0 ; i<10000 ;i++) {
    ActiveAndroid.beginTransaction();
    Student s = new Student();
    s.studentId = "studentId"+i;
    s.name = "name"+i;
    s.teacherName = "teacherName"+i;
    s.claName = "claName"+i;
    s.score = 90;
    s.save();
    ActiveAndroid.setTransactionSuccessful();
    ActiveAndroid.endTransaction();
}

```

realm android 定义orm模型结构并做10000次插入


```java

public class StudentRealm extends RealmObject {
    @PrimaryKey
    private String studentId;
    @Required
    private String name;
    @Required
    private String teacherName;
    @Required
    private String claName;
    private float score;
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public String getClaName() {
        return claName;
    }
    public void setClaName(String ClaName) {
        this.claName = claName;
    }
    public String getTeacherName() {
        return teacherName;
    }
    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
    }
    public String getStudentId() {
        return studentId;
    }
    public void setStudentId(String id) {
        this.studentId = id;
    }
    public float getScore() {
        return score;
    }
    public void setScore(float score) {
        this.score = score;
    }
}
for (int i=0 ; i<10000 ;i++) {
    realm.beginTransaction();
    StudentRealm realmStudent = realm.createObject(StudentRealm.class,"studentId"+i);
    realmStudent.setName("name"+i);
    realmStudent.setTeacherName("setTeacherName"+i);
    realmStudent.setClaName("setClaName"+i);
    realmStudent.setScore(90);
    realm.commitTransaction();
}


```

GreenDao定义orm模型结构并做10000次插入

```java
@Entity()
public class Student {
    @Id
    private String studentId;
    @NotNull
    private String name;
    private String claName;
    private String teacherName;
    private float score;
    @Generated(hash = 1491230551)
    public Student(String studentId, @NotNull String name, String claName, String teacherName,
            float score) {
        this.studentId = studentId;
        this.name = name;
        this.claName = claName;
        this.teacherName = teacherName;
        this.score = score;
    }

    @Generated(hash = 1556870573)
    public Student() {
    }

    public String getStudentId() {
        return studentId;
    }
    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }
    @NotNull
    public String getName() {
        return name;
    }
    /** Not-null value; ensure this value is available before it is saved to the database. */
    public void setName(@NotNull String name) {
        this.name = name;
    }
    public String getClaName() {
        return claName;
    }
    public void setClaName(String claName) {
        this.claName = claName;
    }
    public String getTeacherName() {
        return teacherName;
    }
    public void setTeacherName(String teacherName) {
        this.teacherName = teacherName;
    }
    public float getScore() {
        return score;
    }
    public void setScore(float score) {
        this.score = score;
    }
}

DaoSession daoSession = ((App) getApplication()).getDaoSession();

StudentDao sd = daoSession.getStudentDao();
for (int i = 0; i < 10000; i++) {
    Student s = new Student();
    s.setStudentId("StudentId"+i);
    s.setClaName("getClaName"+i);
    s.setScore(90);
    s.setName("name"+i);
    s.setTeacherName("tn"+i);
    sd.insertOrReplace(s);
}

```

### 批量插入

Luakit没有提供批量插入接口。

active android批量插入10000条数据。

```java

ActiveAndroid.beginTransaction();
for (int i=0 ; i<10000 ;i++) {
    Student s = new Student();
    s.studentId = "studentId"+i;
    s.name = "name"+i;
    s.teacherName = "teacherName"+i;
    s.claName = "claName"+i;
    s.score = 90;
    s.save();
}
ActiveAndroid.setTransactionSuccessful();
ActiveAndroid.endTransaction();


```

realm android批量插入10000条数据。


```java

Realm realm = Realm.getDefaultInstance();
realm.beginTransaction();
for (int i=0 ; i<10000 ;i++) {
    StudentRealm realmStudent = realm.createObject(StudentRealm.class,"studentId"+i);
    realmStudent.setName("name"+i);
    realmStudent.setTeacherName("setTeacherName"+i);
    realmStudent.setClaName("setClaName"+i);
    realmStudent.setScore(90);
}
realm.commitTransaction();

```

GreenDao批量插入10000条数据

```java

DaoSession daoSession = ((App) getApplication()).getDaoSession();
StudentDao sd = daoSession.getStudentDao();
ArrayList<Student> ss = new ArrayList<Student>();
for (int i = 0; i < 10000; i++) {
    Student s = new Student();
    s.setStudentId("StudentId"+i);
    s.setClaName("getClaName"+i);
    s.setScore(90);
    s.setName("name"+i);
    s.setTeacherName("tn"+i);
    ss.add(s);
}
sd.insertOrReplaceInTx(ss);

```

###数据查询

Luakit做10000次查询，下面的代码是ios和android通用的。

```

local studentTable = Table("Student")
for i=1,10000 do
     local result = studentTable.get:where({"studentId"..i},"studentId = ?"):all()
end


```

active android做10000次查询。

```java

for (int i=0 ; i<10000 ;i++) {
    List<Student> student = new Select()
            .from(Student.class)
            .where("studentId = ?", "studentId"+i)
            .execute();
}


```

realm android 做10000次查询。

```java

for (int i=0 ; i<10000 ;i++) {
    RealmResults<StudentRealm> students = realm.where(StudentRealm.class).equalTo("studentId", "studentId"+i).findAll();
    List<StudentRealm> list = realm.copyFromRealm(students);
}

```

GreenDao  做10000次查询

```java

DaoSession daoSession = ((App) getApplication()).getDaoSession();
StudentDao sd = daoSession.getStudentDao();
for (int i = 0; i < 10000; i++) {
    List<Student> s = sd.queryBuilder()
            .where(StudentDao.Properties.StudentId.eq("StudentId"+i))
            .list();
}

```

###循环更新

Luakit做10000次更新。

```

local studentTable = Table("Student")
for i=1,10000 do
    local result = studentTable.get:where({"studentId"..i},"studentId = ?"):update({name = "name2”})
end


```

active android做10000次更新。

```java

for (int i=0 ; i<10000 ;i++) {
    ActiveAndroid.beginTransaction();
    Update update = new Update(Student.class);
    update.set("name = ?","name2")
            .where("studentId = ?", "studentId"+i)
            .execute();
    ActiveAndroid.setTransactionSuccessful();
    ActiveAndroid.endTransaction();
}


```

realm android做10000次更新。

```java

for (int i=0 ; i<10000 ;i++) {
    realm.beginTransaction();
    StudentRealm student = realm.where(StudentRealm.class).equalTo("studentId", "studentId"+i).findFirst();
    student.setClaName("ClaName"+(i+1));
    realm.copyToRealmOrUpdate(student);
    realm.commitTransaction();
}


```

GreenDao做10000次更新。

```java

for (int i = 0; i < 10000; i++) {
    List<Student> s = sd.queryBuilder()
            .where(StudentDao.Properties.StudentId.eq("StudentId"+i))
            .list();
    s.get(0).setName("name2");
    sd.update(s.get(0));
}

```

###批量更新

Luakit没有批量更新接口。

active android批量更新10000条数据。

```java

ActiveAndroid.beginTransaction();
for (int i=0 ; i<10000 ;i++) {
    Update update = new Update(Student.class);
    update.set("name = ?","name2")
            .where("studentId = ?", "studentId"+i)
            .execute();
}
ActiveAndroid.setTransactionSuccessful();
ActiveAndroid.endTransaction();

```

realm android批量更新10000条数据。

```java

realm.beginTransaction();
for (int i=0 ; i<10000 ;i++) {
    StudentRealm student = realm.where(StudentRealm.class).equalTo("studentId", "studentId"+i).findFirst();
    student.setClaName("ClaName"+(i+1));
    realm.copyToRealmOrUpdate(student);
}
realm.commitTransaction();


```

GreenDao批量更新10000条数据

```java

ArrayList<Student> ss = new ArrayList<Student>();
for (int i = 0; i < 10000; i++) {
    List<Student> s = sd.queryBuilder()
            .where(StudentDao.Properties.StudentId.eq("StudentId"+i))
            .list();
    s.get(0).setName("name2");
    ss.add(s.get(0));
}
sd.updateInTx(ss);


```

###循环删除

Luakit做10000次删除操作。

```

local studentTable = Table("Student")
for i=1,10000 do
     studentTable.get:where({"studentId"..i},"studentId = ?"):delete()
end

```

active android做10000次删除操作。

```java

for (int i=0 ; i<10000 ;i++) {
    ActiveAndroid.beginTransaction();
    new Delete().from(Student.class).where("studentId = ?", "studentId"+i).execute();
    ActiveAndroid.setTransactionSuccessful();
    ActiveAndroid.endTransaction();
}

```

realm android做10000次删除操作。

```java

for (int i=0 ; i<10000 ;i++) {
    realm.beginTransaction();
    StudentRealm student = realm.where(StudentRealm.class).equalTo("studentId", "studentId"+i).findFirst();
    student.deleteFromRealm();
    realm.commitTransaction();
}


```

GreenDao做10000次删除操作。

```java

for (int i = 0; i < 10000; i++) {
    List<Student> s = sd.queryBuilder()
            .where(StudentDao.Properties.StudentId.eq("StudentId"+i))
            .list();
    s.get(0).setName("name2");
    sd.delete(s.get(0));
}

```

###批量删除

Luakit没有批量删除接口。

active android批量删除10000条数据。

```java

ActiveAndroid.beginTransaction();
for (int i=0 ; i<10000 ;i++) {
    new Delete().from(Student.class).where("studentId = ?", "studentId"+i).execute();
}
ActiveAndroid.setTransactionSuccessful();
ActiveAndroid.endTransaction();


```

realm android批量删除10000条数据。

```java

realm.beginTransaction();
for (int i=0 ; i<10000 ;i++) {
    StudentRealm student = realm.where(StudentRealm.class).equalTo("studentId", "studentId"+i).findFirst();
    student.deleteFromRealm();
}
realm.commitTransaction();

```

GreenDao批量删除10000条数据。

```java

ArrayList<Student> ss = new ArrayList<Student>();
for (int i = 0; i < 10000; i++) {
    List<Student> s = sd.queryBuilder()
            .where(StudentDao.Properties.StudentId.eq("StudentId"+i))
            .list();
    ss.add(s.get(0));
}
sd.deleteInTx(ss);


```

## android 测试结果及分析

下面给出测试结果，表格中所有数据的单位是秒，即做10000次操作需要的秒数。

![image](https://raw.githubusercontent.com/williamwen1986/Luakit/master/image/android数据1.png)

![image](https://raw.githubusercontent.com/williamwen1986/Luakit/master/image/android数据2.png)

![image](https://raw.githubusercontent.com/williamwen1986/Luakit/master/image/android数据3.png)

* 可以看到，active android各项性能都一般。

* 在使用批量接口的情况下GreenDao和Realm的性能比较好。

* 在使用批量接口的情况下Realm的性能尤其好，批量插入、查询、批量更改、批量删除都是Realm的性能最好，但是Realm的非批量接口性能较差，所有可以这样总结，如果代码高内聚，可以把数据操作代码入口都统一使用，Realm性能是最好的，但这对代码质量、模块设计有要求，当操作数据的代码到处都有，不能使用批量接口时，Realm的性能是不好的。

* [Luakit](https://github.com/williamwen1986/Luakit)没有提供批量接口，但从图中可以看出，Luakit的各项性能指标都是比较好的，而且对代码没有要求，即使操作数据的代码不内聚，也不会对性能有影响。

## ios测试代码

Luakit是跨平台的，代码跟android一样，下面就不列了，只给出Coredata和 Realm ios

### 循环插入

Coredata 定义orm模型结构并做10000次插入

```objc

@interface Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *claName;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) float score;
@property (nullable, nonatomic, copy) NSString *studentId;
@property (nullable, nonatomic, copy) NSString *teacherName;

@end

self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
for (int i=0; i<10000; i++) {
    Student *s = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.context];
    s.studentId = [NSString stringWithFormat:@"studentId%d",i];
    s.name = [NSString stringWithFormat:@"name%d",i];
    s.teacherName = [NSString stringWithFormat:@"teacherName%d",i];
    s.claName = [NSString stringWithFormat:@"claName%d",i];
    s.score = 90;
    NSError *error = nil;
    [self.context save:&error];
}


```

Realm ios定义orm模型结构并做10000次插入

```objc

@interface StudentRLM : RLMObject

@property NSString *studentId;
@property NSString *name;
@property NSString *teacherName;
@property NSString *claName;
@property float score;

@end



for (int i=0; i<10000; i++) {
    [realm beginWriteTransaction];
    StudentRLM *s = [[StudentRLM alloc] init];
    s.studentId = [NSString stringWithFormat:@"studentId%d",i];;
    s.name = [NSString stringWithFormat:@"name%d",i];
    s.teacherName = [NSString stringWithFormat:@"teacherName%d",i];
    s.claName = [NSString stringWithFormat:@"claName%d",i];
    s.score = 90;
    [realm addOrUpdateObject:s];
    [realm commitWriteTransaction];
    [realm beginWriteTransaction];
}

```

### 批量插入

Coredata 批量插入10000条数据。

```objc

for (int i=0; i<10000; i++) {
    Student *s = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:self.context];
    s.studentId = [NSString stringWithFormat:@"studentId%d",i];
    s.name = [NSString stringWithFormat:@"name%d",i];
    s.teacherName = [NSString stringWithFormat:@"teacherName%d",i];
    s.claName = [NSString stringWithFormat:@"claName%d",i];
    s.score = 90;
    
}
NSError *error = nil;
[self.context save:&error];


```

Realm ios批量插入10000条数据。


```objc

[realm beginWriteTransaction];
for (int i=0; i<10000; i++) {
    StudentRLM *s = [[StudentRLM alloc] init];
    s.studentId = [NSString stringWithFormat:@"studentId%d",i];;
    s.name = [NSString stringWithFormat:@"name%d",i];
    s.teacherName = [NSString stringWithFormat:@"teacherName%d",i];
    s.claName = [NSString stringWithFormat:@"claName%d",i];
    s.score = 90;
    [realm addOrUpdateObject:s];
}
[realm commitWriteTransaction];
[realm beginWriteTransaction];


```

### 查询

Coredata 做10000次查询。

```objc

for (int i=0; i<10000; i++) {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    request.predicate = [NSPredicate predicateWithFormat:@"studentId = 'studentId%d'"];
    NSArray *objs = [self.context executeFetchRequest:request error:&error];
}

```

Realm ios做10000次查询。

```objc

for (int i=0; i<10000; i++) {
    RLMResults *results  = [StudentRLM objectsWhere: [NSString stringWithFormat:@"studentId = 'studentId%d'",i]];
    StudentRLM *s = results.firstObject;
}

```

###循环更新

Coredata 做10000次更新。

```objc

for (int i=0; i<10000; i++) {
    NSBatchUpdateRequest *batchUpdateRequest = [[NSBatchUpdateRequest alloc] initWithEntityName:@"Student"];
    batchUpdateRequest.predicate = [NSPredicate predicateWithFormat:@"studentId = 'studentId%d'"];
    batchUpdateRequest.propertiesToUpdate = @{@"name" : @"name2"};
    batchUpdateRequest.resultType = NSUpdatedObjectsCountResultType;
    NSBatchUpdateResult *batchResult = [self.context executeRequest:batchUpdateRequest error:&error];
    NSError *error = nil;
    [self.context save:&error];
}

```

Realm ios做10000次更新。

```objc

for (int i=0; i<10000; i++) {
    [realm beginWriteTransaction];
    RLMResults *results  = [StudentRLM objectsWhere: [NSString stringWithFormat:@"studentId = 'studentId%d'",i]];
    NSLog(@"results %lu",(unsigned long)[results count]);
    StudentRLM *s = results.firstObject;
    [s setName:@"name"];
    [realm addOrUpdateObject:s];
    [realm commitWriteTransaction];
}

```

###批量更新

Coredata 批量更新10000条数据。

```objc

for (int i=0; i<10000; i++) {
    NSBatchUpdateRequest *batchUpdateRequest = [[NSBatchUpdateRequest alloc] initWithEntityName:@"Student"];
    batchUpdateRequest.predicate = [NSPredicate predicateWithFormat:@"studentId = 'studentId%d'"];
    batchUpdateRequest.propertiesToUpdate = @{@"name" : @"name2"};
    batchUpdateRequest.resultType = NSUpdatedObjectsCountResultType;
    NSBatchUpdateResult *batchResult = [self.context executeRequest:batchUpdateRequest error:&error];
}
NSError *error = nil;
[self.context save:&error];


```

Realm ios批量更新10000条数据。

```objc

[realm beginWriteTransaction];
for (int i=0; i<10000; i++) {
    RLMResults *results  = [StudentRLM objectsWhere: [NSString stringWithFormat:@"studentId = 'studentId%d'",i]];
    NSLog(@"results %lu",(unsigned long)[results count]);
    StudentRLM *s = results.firstObject;
    [s setName:@"name”];
    [realm addOrUpdateObject:s];
}
[realm commitWriteTransaction];

```

###循环删除

Coredata 做10000次删除操作。

```objc

for (int i=0; i<10000; i++) {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    request.predicate = [NSPredicate predicateWithFormat:@"studentId = 'studentId%d'"];
    NSBatchDeleteRequest *batchRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    batchRequest.resultType = NSUpdatedObjectsCountResultType;
    NSBatchUpdateResult *batchResult = [self.context executeRequest:batchRequest error:&error];
    NSError *error = nil;
    [self.context save:&error];
}

```

Realm ios做10000次删除操作。

```objc

for (int i=0; i<10000; i++) {
    [realm beginWriteTransaction];
    RLMResults *results  = [StudentRLM objectsWhere: [NSString stringWithFormat:@"studentId = 'studentId%d'",i]];
    StudentRLM *s = results.firstObject;
    [s setName:@"name"];
    [realm deleteObject:s];
    [realm commitWriteTransaction];
}

```

###批量删除

Coredata 批量删除10000条数据。


```objc

for (int i=0; i<10000; i++) {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    request.predicate = [NSPredicate predicateWithFormat:@"studentId = 'studentId%d'"];
    NSBatchDeleteRequest *batchRequest = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    batchRequest.resultType = NSUpdatedObjectsCountResultType;
    NSBatchUpdateResult *batchResult = [self.context executeRequest:batchRequest error:&error];
}
NSError *error = nil;
[self.context save:&error];


```

Realm ios批量删除10000条数据。


```objc

[realm beginWriteTransaction];
for (int i=0; i<10000; i++) {
    RLMResults *results  = [StudentRLM objectsWhere: [NSString stringWithFormat:@"studentId = 'studentId%d'",i]];
    StudentRLM *s = results.firstObject;
    [s setName:@"name"];
    [realm deleteObject:s];
}
[realm commitWriteTransaction];

```

## ios 测试结果及分析

下面给出测试结果，表格中所有数据的单位是秒，即做10000次操作需要的秒数。

![image](https://raw.githubusercontent.com/williamwen1986/Luakit/master/image/ios数据1.png)

![image](https://raw.githubusercontent.com/williamwen1986/Luakit/master/image/ios数据2.png)

![image](https://raw.githubusercontent.com/williamwen1986/Luakit/master/image/ios数据3.png)

* 可以看到，Coredata除了批量插入性能是最好的以外，其他项性能都一般。

* Realm ios和Realm android性能非常相似，批量操作性能优异，但是非批量操作性能一般。可以这样总结，如果代码高内聚，可以把数据操作代码入口都统一使用，Realm性能是最好的，但这对代码质量、模块设计有要求，当操作数据的代码到处都有，不能使用批量接口时，Realm的性能是不好的。

* [Luakit](https://github.com/williamwen1986/Luakit)没有提供批量接口，但从图中可以看出，Luakit的各项性能指标都是比较好的，而且对代码没有要求，即使操作数据的代码不内聚，也不会对性能有影响。