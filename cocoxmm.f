      program cocoxmm

c Convert XMM and CXO ECI linear coords to GSE, GSM coords

c Robert Cameron
c July 2004

c compile and link this program as follows:
c f77 cocoxmm.f ../geopack/GEOPACK.f -o cocoxmm
c
c   updated Feb 10, 2015
c   t. isobe (tisobe@cfa.harvard.edu)
c
c   f77 cocoxmm.f /data/mta/Script/Ephem/Scripts/geopack/geopack.f
c   /data/mta/Script/Ephem/Scripts/geopack/supple.f -o cocoxm

      integer idct(12),ios,yr,mon,d,h,min,s,doy
      real x,y,z,ra,dec,epoch,pi,re,Xgm,Ygm,Zgm,Xge,Yge,Zge
      real*8 t,fy

      data pi /3.14159265359/
      data re /6371.0/
      data idct /0,31,59,90,120,151,181,212,243,273,304,334/


      open(unit=1,name='/data/mta4/proj/rac/ops/ephem/TLE/xmm.j2000')
      open(unit=2,name='/data/mta4/proj/rac/ops/ephem/TLE/xmm.gsme')
      open(unit=3,name='/data/mta4/proj/rac/ops/ephem/TLE/xmm.gsme_in_Re
     & ')
      open(unit=4,name='/data/mta4/proj/rac/ops/ephem/TLE/cxo.j2000')
      open(unit=5,name='/data/mta4/proj/rac/ops/ephem/TLE/cxo.gsme')
      open(unit=8,name='/data/mta4/proj/rac/ops/ephem/TLE/cxo.gsme_in_Re
     & ')

c process XMM data

      do 100 while (ios.eq.0)
         read(1,*,iostat=ios) t,x,y,z,ra,dec,epoch,fy,mon,d,h,min,s

c convert position to km

         x = x/1e3
         y = y/1e3
         z = z/1e3

c calculate day of year (incorrect on centuries)

         yr = int(fy)
         doy = d + idct(mon)
         if (mod(yr,4) .eq. 0 .and. mon .ge. 3) doy = doy + 1

c calculate cartesian coordinates using GEOPACK 

         call recalc_08(yr,doy,h,min,s,Xgeo,Ygeo,Zgeo)
         call geigeo_08(x,y,z,Xgeo,Ygeo,Zgeo,1)
c         call geogsm(Xgeo,Ygeo,Zgeo,Xgsm,Ygsm,Zgsm,1)
         call geogsw_08(Xgeo,Ygeo,Zgeo,Xgsm,Ygsm,Zgsm,1)
c         call gsmgse(Xgsm,Ygsm,Zgsm,Xgse,Ygse,Zgse,1)
         call gswgse_08(Xgsm,Ygsm,Zgsm,Xgse,Ygse,Zgse,1)

c convert to spherical coordinates

         call sphcar_08(R,Tgsm,Pgsm,Xgsm,Ygsm,Zgsm,-1)
         Tgsm = Tgsm * 180 / pi
         Pgsm = Pgsm * 180 / pi
         if (Pgsm .gt. 180) Pgsm = Pgsm - 360
         call sphcar_08(Rgse,Tgse,Pgse,Xgse,Ygse,Zgse,-1)
         Tgse = Tgse * 180 / pi
         Pgse = Pgse * 180 / pi
         if (Pgse .gt. 180) Pgse = Pgse - 360

c convert cartesian coordinates to units of Earth radii

         Xgm = Xgsm/re
         Ygm = Ygsm/re
         Zgm = Zgsm/re
         Xge = Xgse/re
         Yge = Ygse/re
         Zge = Zgse/re

      if (ios.eq.0) write(2,3) t,R,Tgsm,Pgsm,Tgse,Pgse,fy,mon,d,h,min,s
      if (ios.eq.0) write(3,4)t,Xgm,Ygm,Zgm,Xge,Yge,Zge,fy,mon,d,h,min,s
 100  continue
 3    format(f12.1,f10.2,4f8.2,f12.6,5i3)
 4    format(f12.1,6f11.6,f12.6,5i3)

c process CXO data

      ios = 0
      do 200 while (ios.eq.0)
         read(4,*,iostat=ios) t,x,y,z,ra,dec,epoch,fy,mon,d,h,min,s

c convert position to km

         x = x/1e3
         y = y/1e3
         z = z/1e3

c calculate day of year (incorrect on centuries)

         yr = int(fy)
         doy = d + idct(mon)
         if (mod(yr,4) .eq. 0 .and. mon .ge. 3) doy = doy + 1

c calculate cartesian coordinates using GEOPACK 

         call recalc_08(yr,doy,h,min,s,Xgeo,Ygeo,Zgeo)
         call geigeo_08(x,y,z,Xgeo,Ygeo,Zgeo,1)
         call geogsw_08(Xgeo,Ygeo,Zgeo,Xgsm,Ygsm,Zgsm,1)
         call gswgse_08(Xgsm,Ygsm,Zgsm,Xgse,Ygse,Zgse,1)

c convert to spherical coordinates

         call sphcar_08(R,Tgsm,Pgsm,Xgsm,Ygsm,Zgsm,-1)
         Tgsm = Tgsm * 180 / pi
         Pgsm = Pgsm * 180 / pi
         if (Pgsm .gt. 180) Pgsm = Pgsm - 360
         call sphcar_08(Rgse,Tgse,Pgse,Xgse,Ygse,Zgse,-1)
         Tgse = Tgse * 180 / pi
         Pgse = Pgse * 180 / pi
         if (Pgse .gt. 180) Pgse = Pgse - 360

c convert cartesian coordinates to units of Earth radii

         Xgm = Xgsm/re
         Ygm = Ygsm/re
         Zgm = Zgsm/re
         Xge = Xgse/re
         Yge = Ygse/re
         Zge = Zgse/re

      if (ios.eq.0) write(5,3) t,R,Tgsm,Pgsm,Tgse,Pgse,fy,mon,d,h,min,s
      if (ios.eq.0) write(8,4)t,Xgm,Ygm,Zgm,Xge,Yge,Zge,fy,mon,d,h,min,s
 200  continue

      end
