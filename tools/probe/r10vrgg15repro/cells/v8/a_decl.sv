// v8 file A — the DECLARATION lives here; the override actual lives in file B.
module big #(parameter bit [1023:0] BP = '0) (); endmodule
module huge #(parameter bit [65535:0] HP = '0) (); endmodule
module ua  #(parameter bit [3:0] UP [2] = '{default:0}) (); endmodule
module en3 #(parameter bit [2:0] EP = '0) (); endmodule
