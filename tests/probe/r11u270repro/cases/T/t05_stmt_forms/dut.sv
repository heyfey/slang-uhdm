// § sysCallTimeKwNameSpan270
module top;
  int x;
  int seed;
  initial begin
    $display();
    $write();
    x = $random();
    x = $random(seed);
    x = $urandom();
    x = $urandom ();
    x = $time ();
    if ($time() > 5) $finish();
    $stop();
  end
endmodule
