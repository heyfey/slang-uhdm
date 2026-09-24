// § elabNetTdCloneNoAlias134
// case l01: tri1 and wor nets typed by module-local vector typedefs
module top(output logic [7:0] o);
  typedef logic [3:0] n_t;
  typedef logic signed [3:0] s_t;
  tri1 n_t a;
  wor s_t b;
  assign b = 4'sd1;
  assign o = {a, b};
endmodule
