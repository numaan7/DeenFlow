import 'package:flutter/material.dart';

void main() {
  runApp(DeenFlowApp());
}

class DeenFlowApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HabitProvider(),
      child: MaterialApp(
        title: 'DeenFlow',
        theme: ThemeData.dark().copyWith(
          primaryColor: const Color(0xFF1A1A2E),
          scaffoldBackgroundColor: const Color(0xFF16213E),
          cardColor: const Color(0xFF1A1A2E),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00BCD4), // Teal accent
            secondary: Color(0xFF00BCD4),
            surface: Color(0xFF1A1A2E),
            background: Color(0xFF16213E),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A1A2E),
            elevation: 0,
          ),
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Data Models
class Habit {
  final String id;
  final String name;
  final IconData icon;
  int streak;
  bool isCompletedToday;
  DateTime? lastCompletedDate;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    this.streak = 0,
    this.isCompletedToday = false,
    this.lastCompletedDate,
  });

  void complete() {
    if (!isCompletedToday) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      if (lastCompletedDate != null) {
        final lastDate = DateTime(
          lastCompletedDate!.year,
          lastCompletedDate!.month,
          lastCompletedDate!.day,
        );
        
        final daysDifference = today.difference(lastDate).inDays;
        
        if (daysDifference == 1) {
          // Consecutive day
          streak++;
        } else if (daysDifference > 1) {
          // Streak broken
          streak = 1;
        }
      } else {
        // First completion
        streak = 1;
      }
      
      isCompletedToday = true;
      lastCompletedDate = now;
    }
  }

  void resetDailyStatus() {
    isCompletedToday = false;
  }
}

// State Management
class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [
    Habit(
      id: '1',
      name: 'Fajr Salah on Time',
      icon: Icons.brightness_2,
      streak: 3,
    ),
    Habit(
      id: '2',
      name: 'Read 1 Page of Quran',
      icon: Icons.book,
      streak: 7,
    ),
    Habit(
      id: '3',
      name: '30 Seconds of Dhikr',
      icon: Icons.favorite,
      streak: 5,
    ),
  ];

  bool _wakeUpNotificationEnabled = false;

  List<Habit> get habits => _habits;
  bool get wakeUpNotificationEnabled => _wakeUpNotificationEnabled;

  int get overallStreak {
    if (_habits.isEmpty) return 0;
    return _habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
  }

  double get todayConsistencyRate {
    if (_habits.isEmpty) return 0.0;
    final completed = _habits.where((h) => h.isCompletedToday).length;
    return completed / _habits.length;
  }

  void completeHabit(String habitId) {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    habit.complete();
    notifyListeners();
  }

  void toggleWakeUpNotification() {
    _wakeUpNotificationEnabled = !_wakeUpNotificationEnabled;
    notifyListeners();
  }

  void resetDailyProgress() {
    for (var habit in _habits) {
      habit.resetDailyStatus();
    }
    notifyListeners();
  }
}

// Simple Provider Implementation
class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  final T Function(BuildContext context) create;
  final Widget child;

  const ChangeNotifierProvider({
    Key? key,
    required this.create,
    required this.child,
  }) : super(key: key);

  @override
  _ChangeNotifierProviderState<T> createState() => _ChangeNotifierProviderState<T>();

  static T of<T>(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<_InheritedProvider<T>>();
    return provider!.notifier;
  }
}

class _ChangeNotifierProviderState<T extends ChangeNotifier> extends State<ChangeNotifierProvider<T>> {
  late T _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _notifier,
      builder: (context, child) {
        return _InheritedProvider<T>(
          notifier: _notifier,
          child: widget.child,
        );
      },
    );
  }
}

class _InheritedProvider<T> extends InheritedWidget {
  final T notifier;

  const _InheritedProvider({
    Key? key,
    required this.notifier,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedProvider<T> oldWidget) {
    return notifier != oldWidget.notifier;
  }
}

// Screens
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = ChangeNotifierProvider.of<HabitProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DeenFlow',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Card
            _buildStatsCard(context, provider),
            const SizedBox(height: 24),
            
            // Habits Section
            const Text(
              'Today\'s Ibadah',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Habit List
            Expanded(
              child: ListView.builder(
                itemCount: provider.habits.length,
                itemBuilder: (context, index) {
                  return HabitCard(habit: provider.habits[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SquadsScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.group, color: Colors.white),
        label: const Text(
          'Squads',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, HabitProvider provider) {
    final consistencyRate = provider.todayConsistencyRate;
    final overallStreak = provider.overallStreak;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text(
                'Vibe Check',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$overallStreak Day Streak',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Ibadah Streak is on Lock 🔒',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Consistency',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[300],
                ),
              ),
              Text(
                '${(consistencyRate * 100).round()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: consistencyRate,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}

class HabitCard extends StatefulWidget {
  final Habit habit;

  const HabitCard({Key? key, required this.habit}) : super(key: key);

  @override
  _HabitCardState createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ChangeNotifierProvider.of<HabitProvider>(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Habit Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.habit.icon,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Habit Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.habit.streak} days',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Completion Button
                  GestureDetector(
                    onTapDown: (_) => _animationController.forward(),
                    onTapUp: (_) => _animationController.reverse(),
                    onTapCancel: () => _animationController.reverse(),
                    onTap: widget.habit.isCompletedToday
                        ? null
                        : () {
                            provider.completeHabit(widget.habit.id);
                            _showCompletionAnimation(context);
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: widget.habit.isCompletedToday
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        widget.habit.isCompletedToday
                            ? Icons.check
                            : Icons.circle_outlined,
                        color: widget.habit.isCompletedToday
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCompletionAnimation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text('${widget.habit.name} completed! 🎉'),
          ],
        ),
        backgroundColor: Theme.of(context).cardColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = ChangeNotifierProvider.of<HabitProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Wake-up Notification Mock
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: const Text(
                  'Activate Wake-Up Notification',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Show vibe check on lock screen',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                value: provider.wakeUpNotificationEnabled,
                activeColor: Theme.of(context).colorScheme.primary,
                onChanged: (value) {
                  provider.toggleWakeUpNotification();
                  if (value) {
                    _showNotificationMock(context);
                  }
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Home Screen',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            
            // Home Screen Widget Mock
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.widgets,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text(
                  'Generate Home Screen Widget',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Add DeenFlow to your home screen',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () => _showWidgetMock(context, provider),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Reset Daily Progress (for testing)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.refresh,
                  color: Colors.orange,
                ),
                title: const Text(
                  'Reset Daily Progress',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'For testing purposes',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                onTap: () {
                  provider.resetDailyProgress();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Daily progress reset successfully!'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationMock(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              'Notification Active',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: const Text(
          'Notification system is active. Vibe Check will be shown on the lock screen when the device is first unlocked after sleep.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showWidgetMock(BuildContext context, HabitProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text(
          'Home Screen Widget Preview',
          style: TextStyle(color: Colors.white),
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'DeenFlow',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${provider.overallStreak} Day Streak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...provider.habits.map(
                      (habit) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              habit.isCompletedToday
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: habit.isCompletedToday
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                habit.name,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class SquadsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> _leaderboardData = [
    {
      'name': 'Ahmed K.',
      'streak': 15,
      'score': 95,
      'isCurrentUser': false,
    },
    {
      'name': 'You',
      'streak': 12,
      'score': 87,
      'isCurrentUser': true,
    },
    {
      'name': 'Fatima S.',
      'streak': 10,
      'score': 82,
      'isCurrentUser': false,
    },
    {
      'name': 'Omar M.',
      'streak': 8,
      'score': 76,
      'isCurrentUser': false,
    },
    {
      'name': 'Zainab R.',
      'streak': 6,
      'score': 69,
      'isCurrentUser': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Squads Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Theme.of(context).colorScheme.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Weekly Challenge',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Compete with your squad to maintain the longest streak!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView.builder(
                itemCount: _leaderboardData.length,
                itemBuilder: (context, index) {
                  final user = _leaderboardData[index];
                  final isCurrentUser = user['isCurrentUser'] as bool;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: isCurrentUser
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Rank
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? Colors.amber
                                : index == 1
                                    ? Colors.grey[400]
                                    : index == 2
                                        ? Colors.brown[300]
                                        : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: index < 3 ? Colors.white : Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['name'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isCurrentUser
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${user['streak']} days',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Score
                        Column(
                          children: [
                            Text(
                              '${user['score']}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCurrentUser
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.white,
                              ),
                            ),
                            Text(
                              'pts',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}