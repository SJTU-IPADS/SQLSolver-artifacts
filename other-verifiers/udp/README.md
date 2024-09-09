# UDP

## Intro

本工具主要提供了一个python脚本用于一键式地完成从.cos文件翻译到.lean文件再验证的过程。

## SQL Features Covered

引用自[Cosette guide](http://cosette.cs.washington.edu/guide#sql)：

> - `SELECT-FROM-WHERE` queries
> - `DISTINCT` queries
> - `UNION ALL`
> - `GROUP BY` (one or more attributes, currently we don’t support expressions in `GROUP BY` yet)
> - `=`, `>`, and `<` predicates
> - `AND`, `OR`, and `NOT` predicates
> - Aggregates (`SUM`, `COUNT`)
> - Correlated queries (`EXISTS`) and non-Correlated Subqueries (Subqueries in `FROM` clause).

## Getting started

本向导适用于Linux。以下每个小节代表一个步骤，请依次按照指示完成。

### Prepare LeanCodeGen

此步骤是为了生成可执行文件`LeanCodeGen`。

进入目录`Cosette`，执行：

`sudo ./prepare.sh`

此脚本会下载构建环境的Docker镜像，新建Docker容器并将`Cosette`目录映射到容器中，然后自动构建Cosette，将生成的`LeanCodeGen`放入指定目录，退出并删除容器。

构建完Cosette后，可执行文件`LeanCodeGen`将生成于目录`Cosette/uexp/src/uexp/run`下。

### Install Lean 3

若你的系统已经安装过Lean 3，则忽略此步骤。

> 检查系统是否安装Lean 3的步骤：
>
> ```
> $ lean --version
> Lean (version 3.4.2, commit cbd2b6686ddb, Release)
> ```
>
> 若显示的版本并非3.x，或命令未找到，则说明没有安装Lean 3。

下载与操作系统对应的[Lean 3](https://github.com/leanprover/lean/releases/latest)。

假设下载后Lean 3的目录结构如下：

```
/path/to/lean-root/
|- bin/
|- include/
|- lib/
```

请将`/path/to/lean-root/bin`加入环境变量`PATH`。如此就完成了Lean 3的安装。

## Project structure

目录结构如下：

```
. (project root)
|- Cosette/ (Cosette project directory)
   |- prepare.sh (the script to prepare LeanCodeGen)
   |- uexp/src/uexp/run/ (where we run UDP)
      |- auto-udp.py (the program entry)
      |- LeanCodeGen (this file is generated during "getting started" and invoked by auto-udp.py)
   |- ...
|- results/ (results produced by our tests)
|- README.md (this file)
```

## Usage

### Prepare a .cos file

以下是一个.cos文件的例子：

```
schema depts(DName:int, DProj:int);
schema teams(TProj:int, TMember:int); -- TMember is a fk to payroll.Empl
schema payroll(PDept:int, Empl:int); -- Empl is pk
table depts(depts);
table teams(teams);
table payroll(payroll);

unique(payroll, Empl);
foreign(teams, TMember, payroll, Empl);

query q1 
`SELECT t.TMember
    FROM Depts d, Teams t
    WHERE d.Dproj = t.TProj and d.DName = 'Security'`;
    
query q2
` SELECT v1.E
  FROM (SELECT d.DName as D, d.DProj as P, p.Empl as E
        FROM depts d, payroll p
        WHERE d.DName = p.PDept) v1, 
        (SELECT t.TMember as E, p.PDept as D, t.TProj as P
        FROM teams t, payroll p
        WHERE t.TMember = p.Empl) v2
  WHERE v1.D = 'Security' and v1.P = v2.P and v1.E = v2.E and v1.D = v2.D`;
  
verify q1 q2;
```

其中`--`后的内容为单行注释，每条语句结尾均有一个**分号**`;`。

以下将解释.cos文件的组成元素。

#### Schema & table

我们将一张表视作两部分的组合：一部分是表的所有字段名及其类型的信息，称为schema，schema定义了表的每一个tuple的模板；另一部分是表中所有的tuples。因此，为了声明一张表，我们需要先定义它的schema，再声明这张表本身。

在.cos文件中，我们这样描述一张表：

`schema s(attr1:type1, ... , attrN:typeN)`：定义一个具有指定字段的schema `s`，其中第`K`个字段的名为`attrK`、数值类型为`typeK`。

`table t(s)`：声明一张schema为`s`的表`t`。

一张表的名字可以与它的schema名重名。

#### Integrity constraints

支持主键（唯一性）和外键两种约束。

在.cos文件中，我们这样声明完整性约束：

`unique(r, k)`：`k`字段在表`r`中是UNIQUE的。

`foreign(r1, k1, r2, k2)`：表`r1`中的`k1`字段是对表`r2`中的`k2`字段的外键引用；前提要求是定义了约束`unique(r2, k2)`。

#### Query

在.cos文件中，我们这样定义一条查询：

``query qname `SQL` ``：定义一条名为`qname`的查询，查询的SQL语句为`SQL`。

#### Verify

在.cos文件中，我们往往在最后一行加入如下语句：

`verify q1 q2`：验证查询`q1`和`q2`是否等价。

### Place .cos files in categories, Configure the script & Run

#### Run in one batch

我们的工具支持一次性验证多个.cos文件。

比如，我们可以把所有想要验证的.cos文件都放入一个目录`test`下：

```
Cosette/uexp/src/uexp/run
|- test/
   |- test1.cos
   |- test2.cos
   |- ...
   |- test10.cos
|- auto-udp.py
|- LeanCodeGen
```

然后，编辑`auto-udp.py`，将`CATEGORIES`变量设置为`[('my-test-set', './test')]`（`my-test-set`也可以起别的名字）。设置完之后使用**Python 2**运行该脚本。

脚本会对每个.cos文件尝试做验证，并记录**每个文件的结果**（验证成功或失败）以及**统计数据**（总共输入了多少.cos文件，成功验证了多少.cos文件），全部验证完毕后会产生一个结果文件`my-test-set_result.txt`记录这些信息。

#### Run multiple categories

那么，我们如果想把要验证的.cos文件分组，每个组**分别统计**结果，如何做呢？

比如，我们想按照“是否包含完整性约束（IC）”把.cos文件分为两类，然后分别验证和统计。那么我们可以把.cos文件分别（手动）放入两个目录下：

```
Cosette/uexp/src/uexp/run
|- test_ic/
   |- test1.cos
   |- test2.cos
   |- ...
   |- test5.cos
|- test_noic/
   |- test6.cos
   |- test7.cos
   |- ...
   |- test10.cos
|- auto-udp.py
|- LeanCodeGen
```

然后，编辑`auto-udp.py`，将`CATEGORIES`变量设置为`[('IC', './test_ic'), ('NO_IC', './test_noic')]`（`IC`、`NO_IC`也可以起别的名字）。设置完之后使用**Python 2**运行该脚本。全部验证完毕后会产生两个结果文件`IC_result.txt`、`NO_IC_result.txt`。

当然，这个分类是由用户自由完成的，并没有任何硬性的规定或标准，用户可以根据自己的需求给.cos文件分类并分别验证和统计。

### Generated .lean files

生成的.lean文件将保存在和对应.cos文件的同目录下。名为`test.cos`的文件会生成`test.lean`（当验证成功时）或`test_fail.lean`（当验证失败时）。

验证失败有几种可能：

1. .cos文件的语法有误，或使用Cosette/LeanCodeGen不支持的特性，转化.lean失败
2. .cos文件要求证明的两条查询本就不等价
3. .cos文件转化为.lean文件后，.lean文件中的U-exp等式不成立
4. .cos文件转化为.lean文件后，.lean文件中的U-exp等式无法被证明

其中第一种情况生成的.lean中会有错误提示信息而无Lean代码；第二、第三种情况需要人工检查SQL查询是否等价/U-exp是否相等；第四种情况可能是目前证明模板的缺陷，也可能是UDP证明能力的局限，有待进一步挖掘。

## Downsides

对于一个输入文件（验证两条查询是否等价），目前采用预设证明模板，若此证明模板无法验证两条查询等价，那么结果为验证失败。

从`Cosette/examples`下的例子的运行结果来看，除去两条查询本来就不等价，以及Cosette/UDP本身不支持的情况，总共三个分类78个例子，成功验证了其中28个例子（运行结果见`results`）。可见目前预设的证明模板的证明能力尚有提升空间。

