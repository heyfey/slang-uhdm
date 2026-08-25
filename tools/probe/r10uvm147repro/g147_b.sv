// r10uvm147 arm B — the RECEIVER-SYMBOL-KIND axis.  Every NamedValue base kind
// a `<base>.<member>[i]..[range]` reference can have, measured against golden:
// the arm's gate is a slang-side symbol-kind test that Surelog does not have,
// so this arm says which kinds golden actually shapes the same way.
package q147b;

  typedef struct packed { logic [31:0] a; logic [31:0] b; } sp147_t;
  typedef struct { logic [31:0] arr[4]; logic [63:0] pk; } su147_t;

  localparam sp147_t PB = '{a:32'hAA, b:32'hBB};       // a PARAMETER base

  class cel147;
    logic [31:0] value[];
    logic [31:0] p2[2][3];
    logic [63:0] pk;
  endclass

  class own147;
    cel147          h_prop;         // ClassProperty
    static cel147   h_stat;         // static ClassProperty
    su147_t         s_prop;         // ClassProperty of struct type

    function void g(cel147 fa, ref cel147 fr, const ref cel147 fc,
                    int idx, int i);
      cel147 lvar;                  // Variable
      logic [7:0] o;
      o = fa.value[idx][8*i +: 8];      // b01 FormalArgument (input)
      o = fr.value[idx][8*i +: 8];      // b02 FormalArgument (ref)
      o = fc.value[idx][8*i +: 8];      // b03 FormalArgument (const ref)
      o = lvar.value[idx][8*i +: 8];    // b04 Variable            (control)
      o = h_prop.value[idx][8*i +: 8];  // b05 ClassProperty
      o = h_stat.value[idx][8*i +: 8];  // b06 static ClassProperty
      o = this.h_prop.value[idx][8*i +: 8]; // b07 explicit this.
      o = s_prop.arr[idx][8*i +: 8];    // b08 ClassProperty, struct member
      o = PB.a[8*i +: 8];               // b09 Parameter base, no index step
    endfunction

    static function void gs(cel147 fa, int idx, int i);
      logic [7:0] o;
      o = fa.value[idx][8*i +: 8];      // b10 static method, FormalArgument
      o = h_stat.value[idx][8*i +: 8];  // b11 static method, static property
    endfunction

    task tk(cel147 fa, int idx, int i);
      logic [7:0] o;
      o = fa.value[idx][8*i +: 8];      // b12 in a TASK
    endtask
  endclass

  function automatic void f147b(cel147 fa, su147_t sa, int idx, int i);
    logic [7:0] o;
    o = fa.value[idx][8*i +: 8];        // b13 package free function, formal
    o = sa.arr[idx][8*i +: 8];          // b14 struct formal, unpacked member
  endfunction

endpackage

module m147b (input logic clk);
  import q147b::*;
  localparam sp147_t MB = '{a:32'h11, b:32'h22};
  su147_t  mv;                          // module Variable
  cel147   mh;
  int      idx, i;
  logic [7:0] o;
  wire logic [63:0] wnet;

  initial begin
    o = mv.arr[idx][8*i +: 8];          // b15 module Variable   (control)
    o = mh.value[idx][8*i +: 8];        // b16 module class handle
    o = MB.a[8*i +: 8];                 // b17 module Parameter base
  end

  // b18 — a genvar-free generate-less continuous assign over a module variable
  assign o = mv.arr[idx][8*i +: 8];

  // b19 — a FOREACH iterator receiver is the ARRAY, not the loop variable
  initial foreach (mv.arr[j])
    o = mv.arr[j][8*i +: 8];
endmodule
