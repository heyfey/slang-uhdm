// r10earl106 g4_fence106 — THE FENCES, as SHAPES THIS LAW MUST NOT MOVE.
// r10earl105's own head shape ($bits cast over a concat holding a parameter
// read, in a top-level loop-generate body) sits at the top: golden keeps the
// OPERATION there and substitutes the parameter INSIDE it, which is r10earl105's
// law and not this one's.  MEASUREMENT ONLY.
package pg4_106;
  parameter int unsigned NW = 4;
endpackage

module g4_fence106 (output logic [7:0] o);
  localparam logic [pg4_106::NW-1:0] MASKP = {pg4_106::NW{1'b1}};
  logic [7:0]  sleep_mux;
  logic [7:0]  t_ok, t_castcat, t_proc;
  logic [7:0]  t_loc;
  logic [7:0]  t_cast64;

  // A: r10earl105's head shape — a cast over a CONCAT holding a parameter
  //    read, inside a TOP-LEVEL loop-generate body.  Golden keeps op67 and
  //    substitutes MASKP inside it.
  for (genvar k = 0; k < 1; k++) begin : gen_mio_out
    assign sleep_mux = $bits(sleep_mux)'({MASKP, 1'b1, 1'b1, 1'b1});
  end

  // B: the law's OWN shape beside it, same loop body — must convert.
  for (genvar k2 = 0; k2 < 1; k2++) begin : gen_ok
    assign t_ok = 8'(6'h3F);
  end

  // C: a cast over a concat, gen-IF — golden folds, WE keep the operation
  //    (residue: the arm cannot reach it).
  if (1) begin : gen_castcat
    assign t_castcat = 8'({4'h3, 4'hF});
  end

  // D: a PROCEDURAL cast assignment in a gen scope — not a cont_assign at all.
  if (1) begin : gen_proc
    always_comb t_proc = 8'(6'h3F);
  end

  // E: a cast onto a gen-LOCAL declared in an ANCESTOR gen scope (still not a
  //    module-body declaration, so bindVariable still fails).
  if (1) begin : gen_outer
    logic [7:0] anc;
    if (1) begin : gen_inner
      assign anc = 8'(6'h3F);
    end
  end

  // F: a cast whose LHS is a module-body signal but whose value is 64 wide.
  if (1) begin : gen_c64
    assign t_cast64 = 64'(64'hFF);
  end

  assign t_loc = 8'(6'h3F);   // module body control
  assign o = t_ok ^ t_loc ^ sleep_mux ^ t_castcat ^ t_proc ^ t_cast64;
endmodule
