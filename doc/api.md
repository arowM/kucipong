# Back-end API specification

## End user API

For the user who check the coupon.

* No authentication is required for any API
* No user specific information is saved on back-end side
    * Any such data are saved on front-end with localStorage.

### GET recommended coupons

GET recommended coupons data for current user settings.

#### Sample request

Though the behavior of this API implies that it's better to use GET method, it might be good to use POST method to send this complex request with full JSON expression.

```bash
$ curl -G "http://$domain/api/v1/coupon" \
  -d 'areas=[{"latitude": 41.40338, "longitude": 2.17403}]' \
  -d 'tags=[4,6,8,9]' \
  -d 'category=1' \
  -d 'favorites=[2,50,230]' \
  -d 'history=[430,2,220,50,22,300,230]' \
  | jq '.'

{
  xxxxxxxxxxxxxxxxxxx
          TODO
  xxxxxxxxxxxxxxxxxxx
}
```

#### Request Parameter and its type

```haskell
-- Dummy data type representing request parameter from front-end
data RequestParam = RequestParam
  {
    -- Only coupons whose location is near by the any area
    -- specified by this parameter
    areas :: [Area]
    -- Tag IDs that the user chose as he/she is interested in
  , tags  :: [Tag]
    -- Category ID of coupons to show
  , category :: Category
    -- Coupon IDs that the user put it into favorite box
    -- The left side is the coupon ID that the user put it into for the last time
  , favorites :: [CouponId]
    -- Coupon IDs that the user has ever seen details
    -- For practical, the front-end will cut off only N newest history
    -- The left side is the coupon ID that the user saw for the last time
  , history :: [CouponId]
  }

-- ==============
--  Helper Types
-- ==============

data Area = Area
  { latitude :: Latitude
  , longitude :: Longitude
  }
newtype Latitude = Latitude { unLatitude :: Double }
newtype Longitude = Longitude { unLongitude :: Double }
newtype Tag = Tag { unTag :: Int }
newtype Category = Category { unCategory :: Int }
newtype CouponId = CouponId { unCouponId :: Int }
```

#### Response

xxxxxxxxxxxxxxxxxxx
        TODO
xxxxxxxxxxxxxxxxxxx
