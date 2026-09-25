// § varInitStrMethodArgDefNet154
module top;
  string s = "abcd";
  string t = "ab";
  task t1;
    static int b = s.compare(t);
  endtask
endmodule
