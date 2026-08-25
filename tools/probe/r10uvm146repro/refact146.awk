# Emit one record per vpiActual: <owner-kind>|<owner-name>|<owner-loc>|<actual-kind>|<actual-name>|<actual-loc>
{
  line=$0
  n=match(line,/[^ ]/); ind=n-1
  body=substr(line,n)
  if (substr(body,1,2)=="\\_") {
    # node line
    rest=substr(body,3)
    k=rest; sub(/:.*/,"",k)
    nm=""
    if (match(rest,/\(([^)]*)\)/)) { nm=substr(rest,RSTART+1,RLENGTH-2) }
    loc=""
    if (match(rest,/line:[0-9]+:[0-9]+/)) loc=substr(rest,RSTART,RLENGTH)
    node_k[ind]=k; node_n[ind]=nm; node_l[ind]=loc
    if (pend==1 && ind==pend_ind) {
      printf "%s|%s|%s|%s|%s|%s\n", node_k[ind-2], node_n[ind-2], node_l[ind-2], k, nm, loc
      pend=0
    }
    next
  }
  if (substr(body,1,1)=="|") {
    f=substr(body,2); sub(/:.*/,"",f)
    if (f=="vpiActual") { pend=1; pend_ind=ind }
    else pend=0
  }
}
