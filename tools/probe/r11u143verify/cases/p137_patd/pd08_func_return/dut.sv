// § packedArrTdElemRefName137
// case pd08: a packed-array enum typedef as a function return type
module top(output logic [3:0] o);
  typedef enum logic [1:0] {Z0, Z1, Z2} z_t;
  typedef z_t [1:0] za_t;
  function automatic za_t mk(); return {Z1, Z2}; endfunction
  assign o = mk();
endmodule
