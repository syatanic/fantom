//
// Copyright (c) 2010, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   03 Feb 10  Brian Frank  Creation
//

**
** FacetTest
**
class FacetTest : CompilerTest
{

/////////////////////////////////////////////////////////////////////////
// Singleton
//////////////////////////////////////////////////////////////////////////

  Void testSingleton()
  {
    compile("facet class Foo {}")

    t := pod.types.first
    verifyEq(t.name,   "Foo")
    verifyEq(t.isFacet, true)
    verifyEq(t.isClass, true)
    verifyEq(t.isMixin, false)
    verifyEq(t.isConst, true)
    verifyEq(t.isFinal, true)
    verifyEq(t.isAbstract, false)
    verifyEq(t.base, Obj#)
    verifyEq(t.mixins, [Facet#])

    ctor := t.method("make")
    verifyEq(ctor.isPrivate, true)

    defVal := t.field("defVal")
    verifyEq(defVal.isPublic, true)
    verifyEq(defVal.isConst, true)
    verifyEq(defVal.isStatic, true)
    verifyEq(defVal.get.typeof.name, "Foo")
  }

/////////////////////////////////////////////////////////////////////////
// Struct
//////////////////////////////////////////////////////////////////////////

  Void testStruct()
  {
    compile(
      """facet class Foo
         {
           const Int i
           const Str s := "foo"
           const Duration d := 5min
         }
         class Test
         {
           Foo t1() { Foo() }
           Foo t2() { Foo {} }
           Foo t3() { Foo { i = 4 } }
           Foo t4() { Foo { s = "bar" } }
           Foo t5() { Foo { s = "baz"; d = 1day } }
         }
         """)

    t := pod.types.first
    verifyEq(t.name,   "Foo")
    verifyEq(t.isFacet, true)
    verifyEq(t.isConst, true)
    verifyEq(t.base, Obj#)
    verifyEq(t.mixins, [Facet#])

    ctor := t.method("make")
    verifyEq(ctor.isPublic, true)

    test := pod.types[1].make
    verifyStruct(test->t1, 0, "foo", 5min)
    verifyStruct(test->t2, 0, "foo", 5min)
    verifyStruct(test->t3, 4, "foo", 5min)
    verifyStruct(test->t4, 0, "bar", 5min)
    verifyStruct(test->t5, 0, "baz", 1day)
  }

  Void verifyStruct(Obj foo, Int i, Str s, Duration d)
  {
    verifyEq(foo->i, i)
    verifyEq(foo->s, s)
    verifyEq(foo->d, d)
  }

//////////////////////////////////////////////////////////////////////////
// Errors
//////////////////////////////////////////////////////////////////////////

  Void testErrors()
  {
    // InitFacet
    verifyErrors(
     """facet class A { new make() {} }
        """,
       [
         1, 17, "Facet cannot declare constructors",
       ])
  }
}