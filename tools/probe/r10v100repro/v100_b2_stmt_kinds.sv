// r10v100: null, compound, conditional, loop, and event-trigger bodies.
module v100_b2;
  parameter time P = 2;
  int x;
  event ev;
  task automatic run;
    #(P);
    #(P) begin x = 1; x = 2; end
    #(P) if (x) x = 3; else x = 4;
    if (x) #(P) ;
    case (x)
      0: #(P) ;
      default: #(P+1) x = 5;
    endcase
    repeat (2) #(P) ;
    for (int i = 0; i < 2; i++) #(P) ;
    #(P) -> ev;
  endtask
endmodule
