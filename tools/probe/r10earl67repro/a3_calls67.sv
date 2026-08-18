// r10earl67 arm 3 — the CALL-ARGUMENT fence measured on golden at every
// spelling: a BARE user call, a PACKAGE-QUALIFIED user call, a SYSTEM call,
// and a call nested two deep; each with a one-hop gen-scope localparam read
// as a bit-select INDEX in its argument, beside the same read OUTSIDE the
// argument list.  Written after a2_types67.sv scored the un-fenced gate
// 2 pristine-RIGHT -> patched-WRONG on the bare-call cell.
package a3pkg67;
  function automatic logic pf(input logic [15:0] v, input int unsigned k);
    return v[k];
  endfunction
endpackage

module a3_calls67 (input logic [15:0] d, output logic [7:0] y);
  logic [15:0] w;
  assign w = d;
  function automatic logic lf(input logic [15:0] v);
    return ^v;
  endfunction
  for (genvar g = 0; g < 2; g++) begin : hA
    localparam int unsigned Ku = g + 1;
    if (1) begin : hB
      logic o_out, o_bare, o_qual, o_sys, o_deep, o_idxarg;
      assign o_out    = w[Ku];                       // OUTSIDE any call: folds
      assign o_bare   = lf({15'b0, w[Ku]});          // BARE user call arg
      assign o_qual   = a3pkg67::pf({15'b0, w[Ku]}, 0);  // QUALIFIED call arg
      assign o_sys    = ^($signed({15'b0, w[Ku]}));  // SYSTEM call arg
      assign o_deep   = lf({15'b0, lf({15'b0, w[Ku]})}); // call inside a call
      assign o_idxarg = w[Ku] ^ lf(w);               // both in one Rhs
      assign y[g]     = o_out ^ o_bare ^ o_qual ^ o_sys ^ o_deep ^ o_idxarg;
    end
  end
  assign y[7:2] = '0;
endmodule
