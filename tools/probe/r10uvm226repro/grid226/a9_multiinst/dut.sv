// arm a9: an interface instantiated MORE THAN ONCE.  writeInterface copies the
// DEFINITION's one process vector, so the def view must list ONE process per
// written block no matter how many instances exist — and each ELAB view has its
// own.  (Our emitter folds the elab-compiled process back into the def; this
// arm is the cell that says whether that fold is one or many.)
interface if226_m();
   logic clk226;
   logic a226;
   initial begin a226 = 1'b0; end
   always @(posedge clk226) begin a226 <= ~a226; end
endinterface

module mid226_m;
   if226_m u_inner226();
endmodule

module top226_m;
   if226_m u_a226();
   if226_m u_b226();
   mid226_m u_mid226();
endmodule
