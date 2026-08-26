// p6 — a statement-scope typedef used BEFORE its declaration, and the LOOP-BODY
// / case-item homes, and a queue/dynamic/assoc declarator array in a task body.
module mOrder155v;
  initial begin
    typedef byte beforeTd155v;
    beforeTd155v vBefore155v;      // declared BEFORE the use — the legal order
    vBefore155v = 8'd1;
  end
  task automatic tLoop155v(input int n155v);
    for (int i155v = 0; i155v < n155v; i155v++) begin
      typedef byte loopTd155v;
      loopTd155v vLoop155v;
      vLoop155v = 8'd2;
    end
    case (n155v)
      1: begin
        typedef byte caseTd155v;
        caseTd155v vCase155v;
        vCase155v = 8'd3;
      end
      default: ;
    endcase
    while (n155v > 0) begin
      typedef byte whileTd155v;
      whileTd155v vWhile155v;
      vWhile155v = 8'd4;
      n155v--;
    end
  endtask
  task automatic tArr155v();
    typedef int arrTd155v;
    arrTd155v qArr155v [$];
    arrTd155v dArr155v [];
    arrTd155v fArr155v [4];
    arrTd155v aArr155v [string];
    qArr155v.push_back(1);
  endtask
endmodule
