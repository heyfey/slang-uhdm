// v11u59 xv4 — THE SHARED OBJECT.  § r10fsv2 L1 records every pattern element
// in patElabElems and § r10fsv2 RESOLVE hands that VERY OBJECT to an EvalFunc
// member leftover (`st.values[i] = eit->second`).  So the two deleted value
// writes reach not only the package parameter's own listing but every function
// leftover that shares the element.  This arm builds a FuncStructVal-shaped
// row: a function that copies members of the pattern-valued formal into a
// returned struct, so the leftovers exist and are judged.
package pk;
  localparam int unsigned BIG  = 300;
  localparam int unsigned FITS = 7;
  typedef struct packed {
    logic [7:0]   M8;   // BIG  -> over-wide, reachable
    logic [3:0]   M4;   // FITS -> fits
    logic [15:0]  M16;  // BIG  -> fits
    logic [127:0] W;    // 128'(0) -> the walk returns here
    int unsigned  Z;
  } u_t;
  typedef struct packed {
    logic [7:0]  A;
    logic [3:0]  B;
    logic [15:0] C;
    int unsigned D;
  } r_t;
  function automatic r_t mk(u_t c);
    r_t r;
    r.A = c.M8;
    r.B = c.M4;
    r.C = c.M16;
    r.D = c.Z;
    return r;
  endfunction
  localparam u_t BASE = '{ M8: BIG, M4: FITS, M16: BIG, W: 128'(0),
                           Z: unsigned'(64) };
  localparam r_t OUT = mk(BASE);
endpackage
module dut (output logic [31:0] o);
  assign o = {pk::OUT.A, pk::OUT.B[3:0], pk::OUT.C[15:0], 4'h0};
endmodule
