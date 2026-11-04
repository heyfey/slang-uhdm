// § modTdElabFoldSize249 (control: the law does not fire)
module sub; typedef logic [3:0] f_t[5]; f_t x; endmodule
module mid; sub s(); endmodule
module top; mid m(); endmodule
