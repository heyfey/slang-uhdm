// r10earl98 g5 -- THE REFUTED HYPOTHESIS, kept as a NEGATIVE CONTROL.
// The head was first framed as "a SURPLUS elaborated gen-scope variable".
// It is not: golden lists the same 14 logic_vars in the same order and the two
// objects compare EQUAL.  This arm holds the declaration-form x use grid the
// old framing asked for, so the census can SHOW kind and listing already agree.
module n1leaf98 (input logic clk, input logic [7:0] a, output logic [7:0] o);
  if (1) begin : gen_b
    logic              d_scalar;      // plain logic, procedural write
    logic [3:0]        d_ranged;      // packed range
    logic              d_init = 1'b0; // with an initializer
    var logic          d_var;         // the `var` keyword
    wire               d_wire;        // a net
    reg  [3:0]         d_reg;         // reg keyword
    bit                d_bit;
    int                d_int;
    logic [1:0]        d_arr [0:1];   // unpacked array
    logic              d_conly;       // continuous-assign driven only
    logic              d_ffonly;      // always_ff driven only
    logic              d_combonly;    // always_comb driven only
    logic              d_readonly;    // read, never written
    logic              d_none;        // neither read nor written
    assign d_wire   = a[0];
    assign d_conly  = a[1];
    always_ff @(posedge clk) begin
      d_scalar  <= a[2];
      d_ranged  <= a[3:0];
      d_var     <= a[3];
      d_reg     <= a[3:0];
      d_bit     <= a[4];
      d_int     <= {24'd0, a};
      d_arr[0]  <= a[1:0];
      d_ffonly  <= a[5];
    end
    always_comb d_combonly = a[6];
    assign o = {d_scalar, d_ranged[0], d_init, d_var, d_wire, d_reg[0],
                d_bit, d_int[0]} ^ {d_conly, d_ffonly, d_combonly, d_readonly,
                d_arr[0][0], 3'b0};
  end
  logic d_readonly;
  assign d_readonly = 1'b0;
endmodule

module g5_neg98 (input logic clk, input logic [7:0] a, output logic [7:0] o);
  n1leaf98 u_leaf (.clk(clk), .a(a), .o(o));
endmodule
