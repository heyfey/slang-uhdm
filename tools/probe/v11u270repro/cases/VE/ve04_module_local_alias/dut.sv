// § enumAliasCastBindsImportCopy270
module top (input bit [1:0] s, output bit o);
  typedef enum bit [1:0] {I, W, E} sev;
  typedef sev sev_t;
  assign o = (sev_t'(s) == I);
endmodule
