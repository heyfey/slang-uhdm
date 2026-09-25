// § tfArgTypedefLastWriter146
typedef enum {U=11, M, B} pkt_t;
module top;
  class frame_t;
    rand pkt_t ptype;
    function string getType(pkt_t ltype);
      return "x";
    endfunction
  endclass
endmodule
