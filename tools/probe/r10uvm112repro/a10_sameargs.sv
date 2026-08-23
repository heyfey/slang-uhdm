// a10 — CONTENT-NEUTRAL OVERWRITE.  Two typedefs of one foreign generic with
// the SAME argument: the clone half overwrites, but with identical content,
// so nothing may move on either producer.
package pk10box;
  class BoxE10 #(type Q = int, string Nm = "?"); int e10; endclass
endpackage
package pk10use;
  import pk10box::*;
  class shared10; int v10; endclass
  class Ax10;
    typedef BoxE10 #(shared10,"shared10") eid10;
  endclass
  class bz10;
    typedef BoxE10 #(shared10,"shared10") eid10;
  endclass
endpackage
