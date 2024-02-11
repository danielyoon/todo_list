import 'package:todo_list/controller/models/task.dart';
import 'package:todo_list/controller/utils/color_utils.dart';
import 'package:todo_list/core_packages.dart';
import 'package:todo_list/controller/logic/base_todo_provider.dart';
import 'package:todo_list/controller/utils/provider_util.dart';

/*
* TODO: Task shouldn't be marked as completed until ALL dependencies are completed
* TODO: Third level dependency task doesn't work
* TODO: Have a separate category for COMPLETED that only shows at the end
* TODO: Cannot undo middle task
* TODO: Have sort by date due (today, tomorrow, this week, later)
* TODO: Add animation for FAB
* TODO: Add longTap edit menu
* TODO: Add underline for each task UNLESS it has dependencies (?)
* TODO: Make category clickable to see all tasks in one page (?)
* */

class TodoScreen extends StatefulWidget {
  final String title;

  const TodoScreen({super.key, required this.title});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  void _navigateToAdd(BaseTodoProvider provider) {
    appRouter.push('/add/${widget.title}');
  }

  @override
  Widget build(BuildContext context) {
    BaseTodoProvider provider = getProvider(context, widget.title);
    List<Task> miscTasks = provider.getMiscTasks();
    List<Task> completedTasks = provider.getCompletedTasks();
    return Scaffold(
      appBar: _buildAppBar(),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        heroTag: '${widget.title}-button',
        shape: CircleBorder(),
        backgroundColor: ColorUtils.getColorFromTitle(widget.title),
        onPressed: () => _navigateToAdd(provider),
        child: Icon(Icons.add, color: kWhite),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(kToolbarHeight + kSmall * 2),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: kLarge + kSmall),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderWidget(provider: provider, widget: widget),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: provider.subcategory.length,
                    itemBuilder: (context, index) {
                      List<Task> uncompletedTasks = provider.getUncompletedTasks(provider.subcategory.elementAt(index));
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          provider.subcategory.elementAt(index) == 'misc'
                              ? Container()
                              : SizedBox(
                                  height: kSmall + 4,
                                  child: Text(provider.subcategory.elementAt(index).toUpperCase(),
                                      style: kBodyText.copyWith(fontWeight: FontWeight.w700))),
                          provider.subcategory.elementAt(index) == 'misc'
                              ? Container()
                              : Column(
                                  children: uncompletedTasks.map((task) {
                                    if (task.dependentOn == null) {
                                      return CustomTaskViewer(task: task, title: widget.title);
                                    } else {
                                      return Container();
                                    }
                                  }).toList(),
                                ),
                          Gap(kMedium),
                        ],
                      );
                    },
                  ),
                  // miscTasks.isNotEmpty
                  //     ? ListView.builder(
                  //         padding: EdgeInsets.zero,
                  //         physics: NeverScrollableScrollPhysics(),
                  //         shrinkWrap: true,
                  //         itemCount: miscTasks.length,
                  //         itemBuilder: (context, index) {
                  //           return Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               SizedBox(
                  //                   height: kSmall + 4,
                  //                   child: Text('MISC', style: kBodyText.copyWith(fontWeight: FontWeight.w700))),
                  //               Column(
                  //                 children: miscTasks.map((task) {
                  //                   if (task.dependentOn == null) {
                  //                     return CustomTaskViewer(task: task, title: widget.title);
                  //                   } else {
                  //                     return Container();
                  //                   }
                  //                 }).toList(),
                  //               ),
                  //               Gap(kMedium),
                  //             ],
                  //           );
                  //         },
                  //       )
                  //     : Container(),
                  // completedTasks.isNotEmpty
                  //     ? ListView.builder(
                  //         padding: EdgeInsets.zero,
                  //         physics: NeverScrollableScrollPhysics(),
                  //         shrinkWrap: true,
                  //         itemCount: completedTasks.length,
                  //         itemBuilder: (context, index) {
                  //           return Column(
                  //             crossAxisAlignment: CrossAxisAlignment.start,
                  //             children: [
                  //               SizedBox(
                  //                   height: kSmall + 4,
                  //                   child: Text('COMPLETED', style: kBodyText.copyWith(fontWeight: FontWeight.w700))),
                  //               Column(
                  //                 children: completedTasks.map((task) {
                  //                   if (task.dependentOn == null) {
                  //                     return CustomTaskViewer(task: task, title: widget.title);
                  //                   } else {
                  //                     return Container();
                  //                   }
                  //                 }).toList(),
                  //               ),
                  //               Gap(kMedium),
                  //             ],
                  //           );
                  //         },
                  //       )
                  //     : Container(),
                  Gap(kExtraSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: BackButton(
        color: kGrey,
        onPressed: () => Navigator.pop(context, true),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert_rounded, color: kGrey),
          onPressed: () => print('Open sort list'),
        ),
      ],
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    super.key,
    required this.provider,
    required this.widget,
  });

  final BaseTodoProvider provider;
  final TodoScreen widget;

  @override
  Widget build(BuildContext context) {
    Icon getIconFromTitle() {
      switch (widget.title) {
        case 'Personal':
          return Icon(Icons.person, color: kPersonal);
        case 'Work':
          return Icon(Icons.shopping_bag_rounded, color: kWork);
        case 'Bucket':
          return Icon(Icons.star, color: kBucket);
        default:
          return Icon(Icons.person, color: kPersonal);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(kExtraExtraSmall),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kGrey.withOpacity(.4)),
          ),
          child: getIconFromTitle(),
        ),
        Gap(kMedium),
        Text('${provider.getNumberOfUncompletedTasks()} Tasks', style: kSubHeader.copyWith(color: kGrey)),
        Text(widget.title, style: kHeader.copyWith(color: kTextColor.withOpacity(.6))),
        Gap(kMedium),
        Row(
          children: [
            Expanded(
              child: CustomProgressBar(
                  completionPercentage: provider.getRoundedPercentageOfCompletedTasks(),
                  color: ColorUtils.getColorFromTitle(widget.title)),
            ),
            Gap(kExtraExtraSmall),
            Text('${provider.getRoundedPercentageOfCompletedTasks()}%'),
          ],
        ),
        Gap(kSmall),
      ],
    );
  }
}
