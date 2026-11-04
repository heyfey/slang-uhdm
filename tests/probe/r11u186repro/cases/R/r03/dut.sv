// § rootElemAtNextTok186 (control: outside a generate scope)
module top; logic [3:0] v; sub u(); endmodule
module sub; logic [3:0] w; assign w = $root.top.v; endmodule
