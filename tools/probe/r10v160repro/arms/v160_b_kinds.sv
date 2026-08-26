// r10v160 arm B — WHAT THE BAD OPERAND IS BAD ON.
// The type-parameter local's DEFAULT type is varied across int, string, a
// packed STRUCT, an ENUM, a CLASS, a builtin bit/byte/real; the bad face is
// varied across a method call, a member select, a scoped call, a static call
// and a select on a bad type.  MEASUREMENT ONLY.
package pvb160;
  typedef struct packed { int a; int b; } stvb160;
  typedef enum { EB0, EB1 } envb160;
  class basevb160;
    function new(string name="x"); endfunction
    function string gn(); return "g"; endfunction
  endclass

  // b1 default int — method call (the corpus head shape)
  class b1_160 #(type T=int) extends basevb160;
    static string s = "";
    function void m(); T t; s = {"[", t.gt(), "]"};           endfunction
  endclass
  // b2 default STRING — method call on a string
  class b2_160 #(type T=string) extends basevb160;
    static string s = "";
    function void m(); T t; s = {"[", t.gt(), "]"};           endfunction
  endclass
  // b3 default STRUCT — method call
  class b3_160 #(type T=stvb160) extends basevb160;
    static string s = "";
    function void m(); T t; s = {"[", t.gt(), "]"};           endfunction
  endclass
  // b4 default STRUCT — MEMBER SELECT of a member that does not exist
  class b4_160 #(type T=stvb160) extends basevb160;
    static string s = "";
    function void m(); T t; s = {"[", t.nosuch, "]"};         endfunction
  endclass
  // b5 default ENUM — method call
  class b5_160 #(type T=envb160) extends basevb160;
    static string s = "";
    function void m(); T t; s = {"[", t.gt(), "]"};           endfunction
  endclass
  // b6 default CLASS — method that does not exist on it
  class b6_160 #(type T=basevb160) extends basevb160;
    static string s = "";
    function void m(); T t; s = {"[", t.gt(), "]"};           endfunction
  endclass
  // b7 default BIT — method call on a builtin
  class b7_160 #(type T=bit) extends basevb160;
    static string s = "";
    function void m(); T t; s = {"[", t.gt(), "]"};           endfunction
  endclass
  // b8 default BYTE — a SELECT on a bad type
  class b8_160 #(type T=byte) extends basevb160;
    static string s = "";
    function void m(); T t; s = {"[", t.fld.sub, "]"};        endfunction
  endclass
  // b9 default REAL — method call
  class b9_160 #(type T=real) extends basevb160;
    static string s = "";
    function void m(); T t; s = {"[", t.gt(), "]"};           endfunction
  endclass
  // b10 a `::` STATIC call on the type parameter itself
  class b10_160 #(type T=int) extends basevb160;
    static string s = "";
    function void m(); s = {"[", T::mk(), "]"};               endfunction
  endclass
  // b11 a `::` SCOPED NAME on the type parameter
  class b11_160 #(type T=int) extends basevb160;
    static string s = "";
    function void m(); s = {"[", T::tn, "]"};                 endfunction
  endclass
  // b12 a BAD ARGUMENT inside a GOOD call, the call being the operand
  class b12_160 #(type T=int) extends basevb160;
    static string s = "";
    basevb160 bh;
    function void m(); T t; s = {"[", bh.gn(t.gt()), "]"};    endfunction
  endclass
  // b13 NESTED bad inside good inside bad
  class b13_160 #(type T=int) extends basevb160;
    static string s = "";
    basevb160 bh;
    function void m(); T t; s = {"[", bh.gn({"<", t.gt(), ">"}), "]"}; endfunction
  endclass
  // b14 CONTROL — a class whose parameter defaults to a class that DOES have
  //     the method: nothing is bad, both binaries must agree with golden
  class b14_160 #(type T=basevb160) extends basevb160;
    static string s = "";
    function void m(); T t; s = {"[", t.gn(), "]"};           endfunction
  endclass
endpackage

module topvb160;
  initial $display("hi");
endmodule
