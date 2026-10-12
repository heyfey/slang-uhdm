// § dynAssocMemberSpanToDim295
module dut (output logic [7:0] o);
  typedef struct {bit [3:0] m[*];} sq_t;
  sq_t q;
  assign o = 8'h0;
endmodule
