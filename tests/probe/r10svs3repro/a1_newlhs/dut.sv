// r10svs3 ARM a1 — the LHS SHAPE of a dynamic-array `new[...]` assignment.
//
// SVSwitch/Packet.sv holds the natural experiment this arm generalises: two
// ADJACENT methods of the SAME class, each with exactly one `new[...]`:
//   line 71  byte_pack    `bytes = new[data.size + 4];`     golden KEEPS it
//   line 87  byte_unpack  `this.data = new[bytes.size - 4];` golden DROPS it
// Four properties differ between those two sites and any of them could be the
// gate, so each gets its own method here with ONE site in it, so that a
// statement-list length is a per-site verdict:
//   m1  bare LOCAL dynamic-array variable LHS
//   m2  bare REF FORMAL LHS                      (the byte_pack shape)
//   m3  bare CLASS PROPERTY LHS (implicit this)  (isolates `this.` from property)
//   m4  EXPLICIT `this.<property>` LHS           (the byte_unpack shape)
//   m5  explicit `this.<property>` with a `+` size and a formal-free operand
//       (isolates the `-` operator and the `bytes.size` operand from the LHS)
//   m6  ANOTHER OBJECT's property, `h.d = new[..]` (a non-`this` member LHS)
//   m7  bare property LHS with the byte_unpack size expression exactly
//   m8  `this.<property>` with a plain CONSTANT size (no query at all)
//   m9  CONTROL: class-handle `new()` on `this.<property>` (not `new[...]`)
//   m10 CONTROL: `this.<scalar> = <expr>` — an ordinary this-member assignment
//       must NEVER be dropped, or the law is far too wide.
class holder;
  logic [7:0] d[];
  logic [7:0] e[];
  int         s;
  holder      h;

  function void m1();
    logic [7:0] loc[];
    loc = new[3];
  endfunction

  function void m2(ref logic [7:0] bytes[]);
    bytes = new[d.size + 4];
  endfunction

  function void m3();
    d = new[3];
  endfunction

  function void m4();
    this.d = new[3];
  endfunction

  function void m5();
    this.d = new[e.size + 4];
  endfunction

  function void m6();
    h.d = new[3];
  endfunction

  function void m7(ref logic [7:0] bytes[]);
    d = new[bytes.size - 4];
  endfunction

  function void m8();
    this.d = new[7];
  endfunction

  function void m9();
    this.h = new();
  endfunction

  function void m10();
    this.s = 5;
  endfunction
endclass

module top;
  holder hh;
  logic [7:0] b[];
  initial begin
    hh = new();
    hh.m1();
    hh.m2(b);
    hh.m3();
    hh.m4();
    hh.m5();
    hh.m6();
    hh.m7(b);
    hh.m8();
    hh.m9();
    hh.m10();
  end
endmodule
