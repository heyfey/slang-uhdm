// § strLitContLineSpan220
module m;
  initial $display($sformatf("this version of UVM does not properly support memories with \
a smaller word width. \
multiple memory words %0d.", 3));
endmodule
