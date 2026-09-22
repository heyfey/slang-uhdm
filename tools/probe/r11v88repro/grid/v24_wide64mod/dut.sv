// v11u88 v24 -- the MODULE twin of v3: is the ==64 resize the interface
// builder's own or the module home's pre-existing rule?
module dut (output logic [63:0] o);
  wire [31:0] w_64 = 64'd5;
  wire [63:0] w_w64 = 64'd6;
  wire [31:0] w_bare = 7;
  assign o = {32'd0, w_64} ^ w_w64 ^ {32'd0, w_bare};
endmodule
