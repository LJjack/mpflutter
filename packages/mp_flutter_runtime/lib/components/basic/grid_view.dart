part of '../../mp_flutter_runtime.dart';

class _GridView extends ComponentView {
  _GridView({
    Key? key,
    Map? data,
    Map? parentData,
    required _MPComponentFactory componentFactory,
  }) : super(
            key: key,
            data: data,
            parentData: parentData,
            componentFactory: componentFactory);

  @override
  Widget builder(BuildContext context) {
    final gridDelegate = getValueFromAttributes(context, 'gridDelegate');
    final childrenWidget = getWidgetsFromChildren(context);
    if (childrenWidget == null) {
      return const SizedBox();
    }
    final isRoot = getBoolFromAttributes(context, 'isRoot') ?? false;
    Widget widget = SizedBox();
    if (gridDelegate is Map) {
      String classname = gridDelegate['classname'];
      if (classname == 'SliverGridDelegateWithFixedCrossAxisCount') {
        widget = GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing:
                _Utils.toDouble(gridDelegate['mainAxisSpacing'], 0.0),
            crossAxisSpacing:
                _Utils.toDouble(gridDelegate['crossAxisSpacing'], 0),
            crossAxisCount: _Utils.toInt(gridDelegate['crossAxisCount'], 1),
            childAspectRatio:
                _Utils.toDouble(gridDelegate['childAspectRatio'], 0),
          ),
          scrollDirection: (() {
            if (getStringFromAttributes(context, 'scrollDirection') ==
                'Axis.horizontal') {
              return Axis.horizontal;
            } else {
              return Axis.vertical;
            }
          })(),
          padding: getEdgeInsetsFromAttributes(context, 'padding'),
          itemBuilder: (context, index) {
            return childrenWidget[index];
          },
          itemCount: childrenWidget.length,
        );
      } else if (classname == 'SliverGridDelegateWithMaxCrossAxisExtent') {
        widget = GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            mainAxisSpacing: _Utils.toDouble(gridDelegate['mainAxisSpacing']),
            crossAxisSpacing:
                _Utils.toDouble(gridDelegate['crossAxisSpacing'], 0),
            maxCrossAxisExtent:
                _Utils.toDouble(gridDelegate['maxCrossAxisExtent'], 0.0),
            childAspectRatio:
                _Utils.toDouble(gridDelegate['childAspectRatio'], 1.0),
          ),
          scrollDirection: (() {
            if (getStringFromAttributes(context, 'scrollDirection') ==
                'Axis.horizontal') {
              return Axis.horizontal;
            } else {
              return Axis.vertical;
            }
          })(),
          padding: getEdgeInsetsFromAttributes(context, 'padding'),
          itemBuilder: (context, index) {
            return childrenWidget[index];
          },
          itemCount: childrenWidget.length,
        );
      } else if (classname == 'SliverWaterfallDelegate') {
        widget = WaterfallFlow.builder(
          gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            mainAxisSpacing:
                _Utils.toDouble(gridDelegate['mainAxisSpacing'], 0.0),
            crossAxisSpacing:
                _Utils.toDouble(gridDelegate['crossAxisSpacing'], 0.0),
            crossAxisCount: _Utils.toInt(gridDelegate['crossAxisCount'], 0),
          ),
          scrollDirection: (() {
            if (getStringFromAttributes(context, 'scrollDirection') ==
                'Axis.horizontal') {
              return Axis.horizontal;
            } else {
              return Axis.vertical;
            }
          })(),
          padding: getEdgeInsetsFromAttributes(context, 'padding'),
          itemBuilder: (context, index) {
            return childrenWidget[index];
          },
          itemCount: childrenWidget.length,
        );
      }
    }
    if (isRoot) {
      widget = NotificationListener<ScrollNotification>(
        onNotification: (details) {
          final mpPage = context.findAncestorStateOfType<_MPPageState>();
          if (mpPage != null) {
            if (details.metrics.atEdge && details.metrics.pixels > 0) {
              mpPage.onReachBottom();
            }
            mpPage.onPageScroll(details.metrics.pixels);
          }
          return true;
        },
        child: widget,
      );
    }
    return widget;
  }
}
