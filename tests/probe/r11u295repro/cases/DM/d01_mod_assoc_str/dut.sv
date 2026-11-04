// § dynAssocMemberSpanToDim295
module dut (output logic [7:0] o);
  typedef struct {logic [7:0] m[string];} sq_t;
  sq_t q;
  assign o = 8'h0;
endmodule
