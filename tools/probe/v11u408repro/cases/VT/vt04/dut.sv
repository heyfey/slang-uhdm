// § unitTaskNotListed408
task ut;
  $display("x");
endtask
export "DPI-C" task ut;
module top;
endmodule
