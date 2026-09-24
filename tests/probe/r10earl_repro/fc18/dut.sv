// fc18.sv -- r10earl18 witness for the DEF-VIEW GEN-BLOCK QUALIFIED CALL.
// prim_present's head is `func_call 'prim_cipher_pkg::perm_64bit'` vs
// `func_call ''` (a cont_assign inside a gen_if inside a gen_for) and
// prim_prince's is the same shape one level deeper with the NAME right and
// vpiFunction NULL (an always block).  § defGenCallNoBind says a def-view
// gen-block PROCESS call carries name only; this matrix asks whether the
// QUALIFIER is the real discriminator.  Rows (all inside gen_l.gen_a):
//   A  cont_assign, QUALIFIED package call     <- prim_present
//   B  always_comb, QUALIFIED package call     <- prim_prince
//   C  cont_assign, UNQUALIFIED package call (wildcard import)
//   F  always_comb, UNQUALIFIED package call
//   G  always_comb, MODULE-LOCAL call          <- the rggen t2.sv shape
//   H  cont_assign, MODULE-LOCAL call
// plus D/E, the same qualified calls in the module body (controls).
package fp18;
  function automatic logic [7:0] twice(logic [7:0] a);
    twice = a + a;
  endfunction
  function automatic logic [7:0] thrice(logic [7:0] a);
    thrice = a + a + a;
  endfunction
endpackage

module fc18 import fp18::*; #(
  parameter int W = 8
) (
  input  logic [7:0] i0,
  output logic [7:0] oA,
  output logic [7:0] oB,
  output logic [7:0] oC,
  output logic [7:0] oD,
  output logic [7:0] oE,
  output logic [7:0] oF,
  output logic [7:0] oG,
  output logic [7:0] oH
);
  function automatic logic [7:0] locfn(logic [7:0] a);
    locfn = a ^ 8'hAA;
  endfunction

  for (genvar k = 0; k < 1; k++) begin : gen_l
    if (W == 8) begin : gen_a
      assign oA = fp18::twice(i0);
      always_comb begin : p_b
        oB = fp18::thrice(i0);
      end
      assign oC = twice(i0);
      always_comb begin : p_f
        oF = thrice(i0);
      end
      always_comb begin : p_g
        oG = locfn(i0);
      end
      assign oH = locfn(i0);
    end else begin : gen_b
      assign oA = '0;
      assign oB = '0;
      assign oC = '0;
      assign oF = '0;
      assign oG = '0;
      assign oH = '0;
    end
  end

  assign oD = fp18::twice(i0);
  always_comb begin : p_e
    oE = fp18::thrice(i0);
  end
endmodule
