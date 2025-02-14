# FFLib ApexMocks Framework

[FFLIB Mocks GitHub Repo](https://github.com/apex-enterprise-patterns/fflib-apex-mocks) 

**Last Updated From Repo**: 11/15/2024

This Library
============

ApexMocks is a mocking framework for the Salesforce Lightning Apex language. 

It derives its inspiration from the well known Java mocking framework [Mockito](https://site.mockito.org/)

## Using ApexMocks on the Salesforce Lightning Platform

ApexMocks allows you to write tests to both verify behavior and stub dependencies.

An assumption is made that you are using some form of [Dependency Injection](http://en.wikipedia.org/wiki/Dependency_injection) - for example passing dependencies via a constructor:
```Java
public MyClass(ClassA.IClassA dependencyA, ClassB.IClassB dependencyB)
```
This allows you to pass mock implementations of dependencies A and B when you want to unit test MyClass.

Lets assume we've written our own list interface fflib_MyList.IList that we want to either verify or stub:
```Java
public class fflib_MyList implements IList
{
	public interface IList
	{
		void add(String value);
		String get(Integer index);
		void clear();
		Boolean isEmpty();
	}
}
```
### verify() behaviour verification
```Java
// Given
fflib_ApexMocks mocks = new fflib_ApexMocks();
fflib_MyList.IList mockList = (fflib_MyList.IList)mocks.mock(fflib_MyList.class);

// When
mockList.add('bob');

// Then
((fflib_MyList.IList) mocks.verify(mockList)).add('bob');
((fflib_MyList.IList) mocks.verify(mockList, fflib_ApexMocks.NEVER)).clear();
```

If the method wasn't called the expected number of times, or with the expected arguments, verify will throw an exception.
The exception message contains details of the expected and actual invocations:

```
EXPECTED COUNT: 1
ACTUAL COUNT: 0
METHOD: EmailService__sfdc_ApexStub.sendTo(String)
---
ACTUAL ARGS: ("user-two@example.com")
---
EXPECTED ARGS: [[contains "user-one"]]

```

### when() dependency stubbing
```Java
fflib_ApexMocks mocks = new fflib_ApexMocks();
fflib_MyList.IList mockList = (fflib_MyList.IList)mocks.mock(fflib_MyList.class);

mocks.startStubbing();
mocks.when(mockList.get(0)).thenReturn('bob');
mocks.when(mockList.get(1)).thenReturn('fred');
mocks.stopStubbing();
```

## Utilties

### Setting a read-only field, such as a formula

```Java
Account acc = new Account();
Integer mockFormulaResult = 10;
acc = (Account)fflib_ApexMocksUtils.setReadOnlyFields(
		acc,
		Account.class,
		new Map<SObjectField, Object> {Account.Your_Formula_Field__c => mockFormulaResult}
);
System.assertEquals(mockFormulaResult, acc.Your_Formula_Field__c);
```

## Stub API
Using Salesforce's [Stub API](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_stub_api.htm), stub objects are generated dynamically at run time.
```Java
fflib_ApexMocks mocks = new fflib_ApexMocks();
fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);
```

## Documentation

* [ApexMocks Framework Tutorial](http://code4cloud.wordpress.com/2014/05/06/apexmocks-framework-tutorial/)
* [Simple Dependency Injection](http://code4cloud.wordpress.com/2014/05/09/simple-dependency-injection/)
* [ApexMocks Generator](http://code4cloud.wordpress.com/2014/05/15/using-apex-mocks-generator-to-create-mock-class-definitions/)
* [Behaviour Verification](http://code4cloud.wordpress.com/2014/05/15/writing-behaviour-verification-unit-tests/)
* [Stubbing Dependencies](http://code4cloud.wordpress.com/2014/05/15/stubbing-dependencies-in-a-unit-test/)
* [Supported Features](http://code4cloud.wordpress.com/2014/05/15/apexmocks-supported-features/)
* [New Improved apex-mocks-generator](http://code4cloud.wordpress.com/2014/06/27/new-improved-apex-mocks-generator/)
* [ApexMocks Improvements - exception stubbing, base classes and more](http://code4cloud.wordpress.com/2014/11/05/apexmocks-improvements-exception-stubbing-inner-interfaces-and-mock-base-classes/)
* [Matchers](http://superdupercode.blogspot.co.uk/2016/03/apex-mocks-matchers.html)
* [ApexMock blogs from Jesse Altman](http://jessealtman.com/tag/apexmocks/)
* [Order of calls verification](https://xonoxforce.wordpress.com/2017/03/26/inorder-verify/)
* [Answering](https://xonoxforce.wordpress.com/2017/03/31/answering-with-apex-mocks/)
* [Counters](https://xonoxforce.wordpress.com/2017/04/01/counters-in-apex-mocks-verifications/)
* [Troubleshooting](https://salesforce.stackexchange.com/questions/252460/my-apexmocks-arent-working-what-could-be-wrong)
