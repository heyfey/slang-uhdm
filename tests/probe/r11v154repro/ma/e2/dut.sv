// § builtinMethodArgNamedByPath154
module top;
   int q[$];
   int x = 3;
   initial begin
     q.push_back(x);
     q.insert(0, x + 1);
   end
endmodule
