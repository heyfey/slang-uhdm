// § randSequenceDropped401
module top;
  int x, y;
  initial begin
    begin
      randsequence(main) main : { x = 1; }; endsequence
    end
    y = 2;
  end
endmodule
