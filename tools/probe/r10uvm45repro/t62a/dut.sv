// r10uvm45 arm t62a — the THREE UNMEASURED HALVES of § modulePublishesPackage-
// Classes45, each with its own golden row so none of them is inferred.
//
// The law landed this pass is witnessed on MODULE views only (SimpleUVM's
// `$unit` import, SeqDriver's body import).  Three questions it cannot answer:
//
//   (1) KEY COLLISION.  Surelog's DataTypeMap is ONE std::map, so a class key
//       and a same-named typedef cannot both survive; the merge as landed keeps
//       BOTH (class key first) because no golden on the UVM-4 has a collision.
//       `pa63` declares a CLASS named `kname`, `pb63` a TYPEDEF named `kname`,
//       and `m63` wildcard-imports both — never USING the name, so the ambiguity
//       is legal.  Whatever golden's `m63` listing holds at that position is the
//       answer.
//   (2) THE INTERFACE twin — does an interface_inst that imports a
//       class-carrying package publish the class keys into its own vpiTypedef?
//       `i63` asks.
//   (3) THE PROGRAM twin — `p63` asks the same for a program.
//
// Both `base63` and `kname` carry a class-scope `typedef <self> this_type;`,
// which is what mints the class_typespec that becomes the class's
// representative (§ classRepresentativeIsFirstBoundTypedef25) — without one a
// class has no key to publish.
package pa63;
  class base63;
    typedef base63 this_type;
    typedef base63 type_id;
  endclass

  class kname;
    typedef kname this_type;
  endclass

  typedef int a_plain;
endpackage

package pb63;
  typedef int kname;    // COLLIDES with pa63's CLASS name
  typedef int b_plain;
endpackage

module m63;
  import pa63::*;
  import pb63::*;
  int m_x;
endmodule

interface i63;
  import pa63::*;
  logic i_y;
endinterface

program p63;
  import pa63::*;
  initial begin
    $display("p63");
  end
endprogram

module top63;
  m63 u_m();
  i63 u_i();
endmodule
