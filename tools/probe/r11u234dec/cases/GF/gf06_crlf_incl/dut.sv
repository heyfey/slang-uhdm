// § retNameLocalClassTsAtType234: f01 with CRLF endings, the out-of-body body in an included file
package p;
  class region; endclass
  class mam;
    extern function region reserve_region(int n);
  endclass
`include "mam_body.svh"
endpackage
