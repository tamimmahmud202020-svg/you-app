import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/errors/ai_exception.dart';
import '../../models/ai_config.dart';
import '../../providers/settings_provider.dart';
import '../../services/ai_service.dart';

class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  final _keyController = TextEditingController();
  bool _obscureKey = true;
  bool _testing = false;
  String? _testMessage;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<SettingsProvider>();
    _keyController.text = provider.apiKey ?? '';
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final settings = context.watch<SettingsProvider>();
    final config = settings.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Enable AI Features'),
              subtitle: const Text('Generate exams and analysis using AI'),
              value: config.aiEnabled,
              onChanged: (v) async {
                await context.read<SettingsProvider>().setAiEnabled(v);
              },
            ),
          ),
          const SizedBox(height: 16),
          Text('Provider', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonFormField<String>(
                initialValue: config.aiProvider,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.cloud_outlined),
                ),
                items: AiConfig.providers
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(p == 'gemini' ? 'Google Gemini' : p),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    context.read<SettingsProvider>().setAiProvider(v);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Model', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonFormField<String>(
                initialValue: AiConfig.geminiModels.contains(config.aiModel)
                    ? config.aiModel
                    : AiConfig.geminiModels.first,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.memory),
                ),
                items: AiConfig.geminiModels
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    context.read<SettingsProvider>().setAiModel(v);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('API Key', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          TextField(
            controller: _keyController,
            obscureText: _obscureKey,
            decoration: InputDecoration(
              hintText: 'Paste your Gemini API key',
              prefixIcon: const Icon(Icons.vpn_key_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureKey ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _testing ? null : _testConnection,
                  icon: _testing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering),
                  label: Text(_testing ? 'Testing...' : 'Test Connection'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
          if (_testMessage != null) ...[
            const SizedBox(height: 12),
            Card(
              color: _testSuccess
                  ? scheme.primaryContainer
                  : scheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess ? Icons.check_circle : Icons.error,
                      color: _testSuccess ? scheme.primary : scheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testMessage!,
                        style: TextStyle(
                          color: _testSuccess
                              ? scheme.onPrimaryContainer
                              : scheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Card(
            color: scheme.surfaceContainerHighest.withOpacity(0.4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: scheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'How to get a free API key',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Visit aistudio.google.com/app/apikey\n'
                    '2. Sign in with Google\n'
                    '3. Click "Create API Key"\n'
                    '4. Copy the key and paste it above',
                    style: TextStyle(height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Free tier: 1,500 requests per day — enough for personal study.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final provider = context.read<SettingsProvider>();
    await provider.saveApiKey(_keyController.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI settings saved')),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testMessage = null;
    });

    try {
      final key = _keyController.text.trim();
      if (key.isEmpty) {
        setState(() {
          _testSuccess = false;
          _testMessage = 'Please enter an API key first';
          _testing = false;
        });
        return;
      }

      final settings = context.read<SettingsProvider>();
      final config = AiConfig(
        provider: settings.settings.aiProvider,
        model: settings.settings.aiModel,
        enabled: true,
        apiKey: key,
      );

      final service = AiService(config);
      final ok = await service.testConnection();

      if (!mounted) return;
      setState(() {
        _testSuccess = ok;
        _testMessage = ok
            ? 'Connection successful! AI is working.'
            : 'Connection failed. Please try again.';
        _testing = false;
      });
    } on AiException catch (e) {
      if (!mounted) return;
      setState(() {
        _testSuccess = false;
        _testMessage = e.message;
        _testing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testSuccess = false;
        _testMessage = 'Error: $e';
        _testing = false;
      });
    }
  }
}