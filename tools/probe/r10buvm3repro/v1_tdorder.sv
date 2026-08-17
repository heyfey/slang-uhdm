// r10buvm3 arm v1 — the BUILD-ORDER axis, and the ONE thing this law must not
// depend on.  `buildClassTypedefTs` runs either ON DEMAND (from makeTypespec,
// while a variable is being emitted) or IN ORDER (from emitClassTypedefs).
// The three classes below force all three orders for the SAME member shape:
//   f1  declares the property BEFORE the typedef that types it is referenced
//       from anywhere else  -> in-order build
//   f2  is referenced from an EARLIER-SORTED class's property -> on-demand
//   f3  is referenced by a FUNCTION's local var before its own typedefs run
// § aggMemberAggTdSharesListing3 must bind the SAME listing object in all
// three, and the pristine binary must miss it in all three.
package s3;
typedef struct {int a; string b;} pr_t;

class f2;
  typedef struct {pr_t o2; string n2;} bx2_t;
  bx2_t m2;
endclass

class a_first;              // sorts before f2/f3, forces their on-demand build
  f2::bx2_t  early2;
endclass

class f1;
  typedef struct {pr_t o1; string n1;} bx1_t;
  bx1_t m1;
endclass

class f3;
  typedef struct {pr_t o3; string n3;} bx3_t;
  function void g();
    bx3_t l3;      // a FUNCTION LOCAL typed by the class's own nested typedef
  endfunction
  bx3_t m3;
endclass
endpackage
