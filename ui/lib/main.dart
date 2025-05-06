import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/counter_provider.dart';
import 'utils/app_theme.dart';
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
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Uses device theme settings
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
              style: GoogleFonts.roboto(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              ),
            ),
            const SizedBox(height: 10),
            Consumer<CounterProvider>(
              builder: (context, counterProvider, child) {
                return Text(
                  '${counterProvider.count}',
                  style: GoogleFonts.montserrat(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 36),
                    fontWeight: FontWeight.w500,
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
            const SizedBox(height: 20),
            GFCard(
              boxFit: BoxFit.cover,
              title: GFListTile(
                title: Text(
                  'Card Title',
                  style: GoogleFonts.montserrat(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subTitle: Text(
                  'Card Sub Title',
                  style: GoogleFonts.roboto(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 14),
                  ),
                ),
              ),
              content: Text(
                'GetWidget is an open source library that comes with pre-built UI components.',
                style: GoogleFonts.roboto(
                  fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 14),
                ),
              ),
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
                  style: GoogleFonts.roboto(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 18),
                  ),
                ),
                Consumer<CounterProvider>(
                  builder: (context, counterProvider, child) {
                    return Text(
                      '${counterProvider.count}',
                      style: GoogleFonts.montserrat(
                        fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 36),
                        fontWeight: FontWeight.w500,
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
                    style: GoogleFonts.montserrat(
                      fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 20),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subTitle: Text(
                    'Card Sub Title',
                    style: GoogleFonts.roboto(
                      fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 14),
                    ),
                  ),
                ),
                content: Text(
                  'GetWidget is an open source library that comes with pre-built UI components.',
                  style: GoogleFonts.roboto(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 14),
                  ),
                ),
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