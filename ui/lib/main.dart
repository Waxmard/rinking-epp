import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:provider/provider.dart';
import 'providers/counter_provider.dart';
import 'utils/responsive_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CounterProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _incrementCounter(BuildContext context) {
    Provider.of<CounterProvider>(context, listen: false).increment();
  }

  @override
  Widget build(BuildContext context) {
    // Use our helper to check the screen size
    bool isSmallScreen = ResponsiveHelper.isMobile(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: isSmallScreen 
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => Provider.of<CounterProvider>(context, listen: false).decrement(),
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () => _incrementCounter(context),
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              ),
            ),
            const SizedBox(height: 10),
            Consumer<CounterProvider>(
              builder: (context, counterProvider, child) {
                return Text(
                  '${counterProvider.count}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
            const SizedBox(height: 20),
            GFButton(
              onPressed: () => _incrementCounter(context),
              text: 'GF Button',
              shape: GFButtonShape.pills,
              color: GFColors.PRIMARY,
              size: GFSize.LARGE,
            ),
            const SizedBox(height: 20),
            GFCard(
              boxFit: BoxFit.cover,
              title: const GFListTile(
                title: Text('Card Title'),
                subTitle: Text('Card Sub Title'),
              ),
              content: const Text('GetWidget is an open source library that comes with pre-built UI components.'),
              buttonBar: GFButtonBar(
                children: <Widget>[
                  GFButton(
                    onPressed: () {},
                    text: 'Read More',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'You have pushed the button this many times:',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 18),
                  ),
                ),
                Consumer<CounterProvider>(
                  builder: (context, counterProvider, child) {
                    return Text(
                      '${counterProvider.count}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 36),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                GFButton(
                  onPressed: () => _incrementCounter(context),
                  text: 'GF Button',
                  shape: GFButtonShape.pills,
                  color: GFColors.PRIMARY,
                  size: GFSize.LARGE,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: ResponsiveHelper.getScreenPadding(context),
              child: GFCard(
                boxFit: BoxFit.cover,
                title: GFListTile(
                  title: Text(
                    'Desktop Card Title',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 20),
                    ),
                  ),
                  subTitle: Text(
                    'Card Sub Title',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 14),
                    ),
                  ),
                ),
                content: const Text('GetWidget is an open source library that comes with pre-built UI components.'),
                buttonBar: GFButtonBar(
                  children: <Widget>[
                    GFButton(
                      onPressed: () {},
                      text: 'Read More',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}