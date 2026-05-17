import 'package:flutter/material.dart';

void main() {
  runApp(const ImterSite());
}

class ImterSite extends StatelessWidget {
  const ImterSite({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xff2f7d73);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      surface: const Color(0xfff7faf8),
    );

    return MaterialApp(
      title: 'Imter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        textTheme: Typography.material2021().black.apply(
          bodyColor: const Color(0xff17201d),
          displayColor: const Color(0xff17201d),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: const [
            HeroBand(),
            FormatBand(),
            WorkflowBand(),
            DeployBand(),
            FooterBand(),
          ],
        ),
      ),
    );
  }
}

class HeroBand extends StatelessWidget {
  const HeroBand({super.key});

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = viewportHeight.clamp(620.0, 760.0).toDouble() * 0.88;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/imter_logo.png',
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
            color: Colors.white.withValues(alpha: 0.88),
            colorBlendMode: BlendMode.srcATop,
          ),
          const _FormatConstellation(),
          Container(color: const Color(0xfff7faf8).withValues(alpha: 0.82)),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      const SiteNav(),
                      const Spacer(),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Imter',
                              style: textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 76,
                                height: 0.95,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'A fully local desktop image converter for JPEG, PNG, WebP, AVIF, GIF, TIFF, BMP, and ICO.',
                              style: textTheme.headlineSmall?.copyWith(
                                height: 1.25,
                                color: const Color(0xff32423d),
                              ),
                            ),
                            const SizedBox(height: 28),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: const [
                                _HeroButton(
                                  filled: true,
                                  icon: Icons.desktop_mac_rounded,
                                  label: 'macOS ready',
                                ),
                                _HeroButton(
                                  filled: false,
                                  icon: Icons.lock_outline_rounded,
                                  label: 'Fully local',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SiteNav extends StatelessWidget {
  const SiteNav({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/imter_logo.png',
                width: 38,
                height: 38,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Imter',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const Spacer(),
            if (!compact) ...[
              const _NavLabel('Formats'),
              const SizedBox(width: 18),
              const _NavLabel('Workflow'),
              const SizedBox(width: 18),
              const _NavLabel('Deploy'),
            ],
          ],
        );
      },
    );
  }
}

class _NavLabel extends StatelessWidget {
  const _NavLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: const Color(0xff43534e),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.filled,
    required this.icon,
    required this.label,
  });

  final bool filled;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 20), const SizedBox(width: 8), Text(label)],
    );
    return filled
        ? FilledButton(onPressed: () {}, child: child)
        : OutlinedButton(onPressed: () {}, child: child);
  }
}

class _FormatConstellation extends StatelessWidget {
  const _FormatConstellation();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('JPEG', 0.70, 0.18),
      ('PNG', 0.82, 0.34),
      ('WebP', 0.64, 0.48),
      ('AVIF', 0.88, 0.58),
      ('TIFF', 0.72, 0.72),
      ('GIF', 0.56, 0.30),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return const SizedBox.shrink();
        }
        return Stack(
          children: [
            for (final item in items)
              Positioned(
                left: constraints.maxWidth * item.$2,
                top: constraints.maxHeight * item.$3,
                child: _FloatingFormat(label: item.$1),
              ),
          ],
        );
      },
    );
  }
}

class _FloatingFormat extends StatelessWidget {
  const _FloatingFormat({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        border: Border.all(color: const Color(0xffc6d8d2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xff213a34),
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class FormatBand extends StatelessWidget {
  const FormatBand({super.key});

  @override
  Widget build(BuildContext context) {
    return _Band(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            kicker: 'Formats',
            title: 'Modern web formats and the classics.',
            body:
                'Pick an output by comparing approximate file size, transparency support, and practical tradeoffs before converting.',
          ),
          const SizedBox(height: 26),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _FormatChip('JPEG'),
              _FormatChip('PNG'),
              _FormatChip('WebP'),
              _FormatChip('AVIF'),
              _FormatChip('GIF'),
              _FormatChip('TIFF'),
              _FormatChip('BMP'),
              _FormatChip('ICO'),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkflowBand extends StatelessWidget {
  const WorkflowBand({super.key});

  @override
  Widget build(BuildContext context) {
    return _Band(
      color: const Color(0xffedf5f1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            kicker: 'Workflow',
            title: 'Conversion without the upload tax.',
            body:
                'Imter keeps files on the device, exposes practical controls, and includes a learning view for choosing the right format.',
          ),
          const SizedBox(height: 28),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final cards = const [
                _FeatureTile(
                  icon: Icons.folder_open_rounded,
                  title: 'Drop or choose',
                  body:
                      'Open a local image and inspect dimensions, alpha, frames, and original size.',
                ),
                _FeatureTile(
                  icon: Icons.tune_rounded,
                  title: 'Tune output',
                  body:
                      'Adjust quality, lossless modes, compression effort, resizing, and matte color.',
                ),
                _FeatureTile(
                  icon: Icons.query_stats_rounded,
                  title: 'Compare first',
                  body:
                      'Review approximate output size across formats before writing a file.',
                ),
              ];
              return compact
                  ? Column(children: cards)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final card in cards) Expanded(child: card),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class DeployBand extends StatelessWidget {
  const DeployBand({super.key});

  @override
  Widget build(BuildContext context) {
    return _Band(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SectionHeader(
            kicker: 'Website',
            title: 'Built as Flutter web.',
            body:
                'The product site is static and can be deployed from the generated build/web folder to GitHub Pages, Vercel, Netlify, or any static host.',
          ),
          SizedBox(height: 22),
        ],
      ),
    );
  }
}

class FooterBand extends StatelessWidget {
  const FooterBand({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xff16231f),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Wrap(
            spacing: 10,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/imter_logo.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Imter 0.1.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const Text(
                'Local image conversion for desktop.',
                style: TextStyle(color: Color(0xffc6d8d2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Band extends StatelessWidget {
  const _Band({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 72),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: child,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.kicker,
    required this.title,
    required this.body,
  });

  final String kicker;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 780),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kicker,
            style: textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: textTheme.bodyLarge?.copyWith(
              color: const Color(0xff4f625c),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xfff2f7f4),
        border: Border.all(color: const Color(0xffc8d9d3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xff213a34),
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14, bottom: 14),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xffc8d9d3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: const TextStyle(color: Color(0xff4f625c), height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommandBlock extends StatelessWidget {
  const _CommandBlock({required this.commands});

  final List<String> commands;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff16231f),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final command in commands)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  command,
                  style: const TextStyle(
                    color: Color(0xffd8f0e8),
                    fontFamily: 'monospace',
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
