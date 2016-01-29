前段时间，在项目上做了一些地图相关的功能，解决了三个特殊需求，在此总结一下，以备日后使用：
>**1. MKOverlayView的拖动实现；**
**2. 大头针pin 的拖动实现；**
**3. 随地图的缩放而缩放的焦点框功能实现；**

***
###1. MKOverlayView的拖动实现
首先，直接给MKOverlayView视图本身添加一个拖动手势是不可行的，因为MKOverlayView不是通过简单的`addSubview:`添加到地图图层上的。

MKOverlayView视图的现实过程：
1.1 使用MKPolygon的`addOverlay:`方法来添加OverlayView数据
源overlay，其中包括了图层的经纬度坐标数据。

```
CLLocationCoordinate2D leftUp = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude - gap);
CLLocationCoordinate2D rightUp = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude - gap);
CLLocationCoordinate2D leftDown = CLLocationCoordinate2DMake(center.latitude - gap, center.longitude + gap);
CLLocationCoordinate2D rightDown = CLLocationCoordinate2DMake(center.latitude + gap, center.longitude + gap);

CLLocationCoordinate2D coordinates[4] = {leftUp, leftDown, rightUp, rightDown};
MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coordinates count:4];
[m_MapView addOverlay:polygon];
```

1.2 然后再实现MKMapView的代理方法：

```
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
MKOverlayView *pview = [[MKOverlayView alloc] initWithOverlay:overlay];
pview.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.4f];    

return pview;
}```

这样就会给地图的图层中嵌入一个指定位置和大小的视图，效果上是与地图合为一体的，可以一起移动和缩放，

也就是说通过`addOverlay: `来添加视图的数据源，然后在

```
-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay```

方法中去绘制视图本身（图层颜色，也可以绘制文字在上面）。

MKOverlayView的类型参数有以下几种：

| 数据类    | 对应view    | 说明    |
| :-------: | :----:| :-----: |
| MKPolygon         | MKOverlayView   | 矩形      |
| MKCircle         | MKCircleView   | 圆形      |
| MKPolyline         | MKPolylineView   | 线条      |

那如何拖动MKOverlayView呢？

```
- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(nullable UIView *)view
```

使用上述方法将MKOverlayView的经纬度坐标转化为相对于MKMapView的点坐标，然后在同样的位置加上一个同样大小的透明子视图，给自视图添加拖动手势`UIPanGestureRecognizer`，每次拖动的时候先使用`removeOverlay:`删除之前的MKOverlayView，然后再重新以拖动点为中心，加载新的MKOverlayView即可，效果很良好，不会出现闪烁的现象。
由于地图本身可以放大，缩小，移动，所以在这些操作之后也需要调整这个子视图的大小：

```
//当拖拽，放大，缩小，双击手势开始时调用
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
//当拖拽，放大，缩小，双击手势结束时调用
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
```

***
###2. 大头针pin 的拖动实现；
拖动大头针的方法系统API有提供：
-  新建一个继承`<MKAnnotation>`协议的大头针数据类，并添加坐标coordinate，title，subtitle属性；
-  使用`addAnnotation:`添加大头针数据源，在

```
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
```

方法中添加大头针视图`MKPinAnnotationView`，并且设置拖动属性为YES：`pin.draggable = YES;`
- 下面方法是拖拽回调方法，在`MKAnnotationViewDragStateEnding`状态时，调整大头针位置即可

```
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
```

最后的效果就是长按大头针，会有一个大头针升起的动画，然后拖动释放又会有大头针落下的动画，效果很炫。

这是使用系统方法实现大头针的拖拽，其实也可以使用1中拖拽MKOverlayView的方法，在大头针的位置放一个透明的子视图，然后拖动这个子视图的同时，移除旧的大头针，再在相应位置添加新的大头针即可。
只不过这就没有大头针升起/落下的动画了，当然，也不用长按大头针才能拖动，你可以自定义。
***
###3. 随地图的缩放而缩放的焦点框功能实现

由于系统没有提供MKMapView的缩放比例，所以得自己计算这个比例：
- 地图缩放的时候其实是`MKCoordinateSpan`在变化

```
typedef struct {
    CLLocationDegrees latitudeDelta;//纬度范围
    CLLocationDegrees longitudeDelta;//纬度范围
} MKCoordinateSpan;
```

- 比例计算公式
            float ratio  = oldSpanArea/newSpan
说明：老的span面积/新的span面积
span面积＝latitudeDelta ＊ longitudeDelta

- 最后计算焦点框的边长
float width = sqrtf(ratio * (fenceView.frame.size.width * fenceView.frame.size.height));
然后改变焦点框的frame就可以了。
当然，最后的计算赋值都在缩放结束后的函数中进行：

````
//当拖拽，放大，缩小，双击手势结束时调用
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
````

***
###补充:
前几天对地图这边做优化，发现方案三还可以有另一种做法：
可以通过给mapview对象添加：
`UIPanGestureRecognizer，UITapGestureRecognizer，UIPinchGestureRecognizer`
三种手势来监听对地图的拖动，点击，缩放的事件，既然监听到了这些事件，那么后面的事情就好办了。

当然，不要忘了在代码中实现`UIGestureRecognizerDelegate`的这个方法：

````
// called when the recognition of one of gestureRecognizer or otherGestureRecognizer would be blocked by the other
// return YES to allow both to recognize simultaneously. the default implementation returns NO (by default no two gestures can be recognized simultaneously)
//
// note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
return YES;
}
````

这个方法的意思是：
当一个手势被另外一个手势堵塞后，就会调用这个回调，默认是返回NO的，
如果返回YES的话，才会允许多个手势共存。

以上补充已在demo中添加。

***
Demo下载链接：[CamouflageLocationDemo](https://github.com/Kangqj/Demo/tree/master/CamouflageLocationDemo)